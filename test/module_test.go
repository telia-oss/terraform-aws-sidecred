package module_test

import (
	"fmt"
	"strings"
	"testing"

	module "github.com/telia-oss/terraform-aws-sidecred/test"

	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
)

func TestModule(t *testing.T) {
	tests := []struct {
		description     string
		directory       string
		name            string
		region          string
		events          []string
		expected        module.Expectations
		generatesConfig bool
	}{
		{
			description: "basic example",
			directory:   "../examples/basic",
			name:        fmt.Sprintf("sidecred-basic-test-%s", random.UniqueId()),
			region:      "eu-west-1",
			events: []string{
				`{"namespace":"example","config_path":"example/config.yml","state_path":"example/config.yml.state"}`,
			},
			expected: module.Expectations{
				Parameters: []string{"/sidecred/example/random-string-1", "/sidecred/example/random-string-2"},
			},
		},
		{
			description: "complete example",
			directory:   "../examples/complete",
			name:        fmt.Sprintf("sidecred-complete-test-%s", random.UniqueId()),
			region:      "eu-west-1",
			events: []string{
				`{"namespace":"example","config_path":"example/config.yml","state_path":"example/config.yml.state"}`,
				`{"namespace":"example","config_path":"example/generated-config.yml","state_path":"example/generated-config.yml.state"}`,
			},
			expected: module.Expectations{
				Parameters: []string{"/sidecred/example/random-string-3", "/sidecred/example/sts-credential-1-access-key"},
			},
			generatesConfig: true,
		},
	}

	for _, tc := range tests {
		tc := tc // Source: https://gist.github.com/posener/92a55c4cd441fc5e5e85f27bca008721
		t.Run(tc.description, func(t *testing.T) {
			t.Parallel()

			options := &terraform.Options{
				TerraformDir: tc.directory,
				Vars: map[string]interface{}{
					// Bucket name needs to be lowercase.
					"name_prefix": strings.ToLower(tc.name),
					"region":      tc.region,
				},
				EnvVars: map[string]string{
					"AWS_DEFAULT_REGION": tc.region,
				},
			}

			defer terraform.Destroy(t, options)

			// Terraform does not include the local file in the dependency graph.
			// Hence we need to apply with a target to generate the config first.
			if tc.generatesConfig {
				options.Targets = []string{"local_file.config"}
				terraform.InitAndApply(t, options)
				options.Targets = nil
			}

			terraform.InitAndApply(t, options)

			lambdaARN := terraform.Output(t, options, "arn")
			module.RunTestSuite(t, lambdaARN, tc.events, tc.region, tc.expected)
		})
	}
}
