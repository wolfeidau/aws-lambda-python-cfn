#!/usr/bin/env ruby

require 'bundler/setup'
require 'cloudformation-ruby-dsl/cfntemplate'
require 'cloudformation-ruby-dsl/spotprice'
require 'cloudformation-ruby-dsl/table'

template do
  value AWSTemplateFormatVersion: '2010-09-09'

  value Description: 'AWS CloudFormation'

  resource 'LambdaExecutionRole', Type: 'AWS::IAM::Role', Properties: {
    AssumeRolePolicyDocument: {
      Version: '2012-10-17',
      Statement: [
        {
          Effect: 'Allow',
          Principal: { Service: ['lambda.amazonaws.com'] },
          Action: ['sts:AssumeRole']
        }
      ]
    },
    Path: '/',
    ManagedPolicyArns: [
      'arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess',
      'arn:aws:iam::aws:policy/service-role/AWSConfigRulesExecutionRole',
      'arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole'
    ]
  }

  resource 'ConfigPermissionToCallLambda', Type: 'AWS::Lambda::Permission', Properties: {
    FunctionName: get_att('Ec2TagComplianceCheck', 'Arn'),
    Action: 'lambda:InvokeFunction',
    Principal: 'config.amazonaws.com'
  }

  resource 'Ec2TagComplianceCheck', Type: 'AWS::Lambda::Function', Properties: {
    Code: {
      ZipFile: interpolate(file('ec2_required_tags.py'))
    },
    Handler: 'index.lambda_handler',
    Runtime: 'python2.7',
    Timeout: '60',
    Role: get_att('LambdaExecutionRole', 'Arn')
  }

  resource 'ConfigRuleForEc2TagCompliance', Type: 'AWS::Config::ConfigRule', DependsOn: 'ConfigPermissionToCallLambda', Properties: {
    ConfigRuleName: 'ConfigRuleForEc2TagCompliance',
    Scope: {
      ComplianceResourceTypes: ['AWS::EC2::Instance']
    },
    InputParameters: {
      Environment: 'Stage,Dev,Prod'
    },
    Source: {
      Owner: 'CUSTOM_LAMBDA',
      SourceDetails: [
        { EventSource: 'aws.config', MessageType: 'ConfigurationItemChangeNotification' }
      ],
      SourceIdentifier: get_att('Ec2TagComplianceCheck', 'Arn')
    }
  }
end.exec!
