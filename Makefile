default: validate

bundle:
	bundle install --path vendor/bundle

check-bundle: ; @test -d vendor || ( echo "Run \"make bundle\" to install ruby dependencies" && exit 1 )
templates: check-bundle
	mkdir -p templates
	bundle exec ruby ec2_required_tags.rb expand > templates/ec2_required_tags.template

validate: templates
	bundle exec cfn_nag --input-json-path templates/*.template

.PHONY: bundle check-bundle templates
