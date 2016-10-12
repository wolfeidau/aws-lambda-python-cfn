# aws-lambda-python-cfn

This project is a simple example of how to deploy a lambda a custom config rule written in python and using [cloudformation](https://aws.amazon.com/cloudformation/).

To simplify maintaining this code [cloudformation-ruby-dsl](https://github.com/bazaarvoice/cloudformation-ruby-dsl) is used to build the template.

# building

To build and validate the template you will need ruby 2.x installed then run bundler to install the dependencies. If your on a mac and you don't have bundler you need to run `sudo gem install bundler`.

```
make bundle
```

Then to build the template.

```
make
```

This will create `templates/ec2_required_tags.template` in the project directory.

# other config examples

The code from this python lambda function came from https://github.com/awslabs/aws-config-rules.

# licence

This project is made available under CC0 1.0 Universal (https://creativecommons.org/publicdomain/zero/1.0/legalcode)
