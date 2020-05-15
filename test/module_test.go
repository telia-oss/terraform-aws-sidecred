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
		description string
		directory   string
		name        string
		region      string
		expected    module.Expectations
	}{
		{
			description: "basic example",
			directory:   "../examples/basic",
			name:        fmt.Sprintf("sidecred-basic-test-%s", random.UniqueId()),
			region:      "eu-west-1",
			expected: module.Expectations{
				Parameters: []string{"/sidecred/example/random-string-1", "/sidecred/example/random-string-2"},
			},
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
			terraform.InitAndApply(t, options)

			lambdaARN := terraform.Output(t, options, "arn")
			module.RunTestSuite(t, lambdaARN, tc.region, tc.expected)
		})
	}
}
