package module

import (
	"testing"
	"time"

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/lambda"
	"github.com/aws/aws-sdk-go/service/ssm"
)

// Expectations for the test suite.
type Expectations struct {
	Parameters []string
}

// RunTestSuite for the module.
func RunTestSuite(t *testing.T, lambdaARN string, events []string, region string, expected Expectations) {
	var (
		sess      = NewSession(t, region)
		testStart = time.Now()
	)

	time.Sleep(5 * time.Second)

	// Invoke sidecred using the specified events
	// (and wait for it to finish execution)
	for _, event := range events {
		InvokeFunction(t, sess, lambdaARN, event)
	}

	params := ListParameters(t, sess, expected.Parameters)
	for _, param := range expected.Parameters {
		p, ok := params[param]
		if !ok {
			t.Errorf("could not find expected parameter: %s", param)
			continue
		}
		if d := p.LastModifiedDate; d.Before(testStart) {
			t.Errorf("parameter '%s' was not updated: %s", param, d.Format(time.RFC3339))
			continue
		}
	}
}

// NewSession for AWS.
func NewSession(t *testing.T, region string) *session.Session {
	sess, err := session.NewSession(&aws.Config{
		Region: aws.String(region),
	})
	if err != nil {
		t.Fatalf("failed to create new AWS session: %s", err)
	}
	return sess
}

// InvokeFunction ...
func InvokeFunction(t *testing.T, sess *session.Session, lambdaARN, payload string) {
	c := lambda.New(sess)

	_, err := c.Invoke(&lambda.InvokeInput{
		FunctionName: aws.String(lambdaARN),
		Payload:      []byte(payload),
	})
	if err != nil {
		t.Fatalf("failed to invoke function: %s", err)
	}
}

// ListParameters ...
func ListParameters(t *testing.T, sess *session.Session, names []string) map[string]*ssm.ParameterMetadata {
	c := ssm.New(sess)

	var (
		nextToken  *string
		parameters = make(map[string]*ssm.ParameterMetadata)
	)
	for {
		out, err := c.DescribeParameters(&ssm.DescribeParametersInput{
			NextToken: nil,
			ParameterFilters: []*ssm.ParameterStringFilter{
				{
					Key:    aws.String("Name"),
					Option: aws.String("Equals"),
					Values: aws.StringSlice(names),
				},
			},
		})
		if err != nil {
			t.Fatalf("failed to get parameters by path: %s", err)
		}
		for _, p := range out.Parameters {
			parameters[aws.StringValue(p.Name)] = p
		}
		nextToken = out.NextToken
		if nextToken == nil {
			break
		}
	}
	return parameters
}
