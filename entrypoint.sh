#!/bin/bash
set -e

install_zip_dependencies(){
	echo "Installing and zipping dependencies..."
	mkdir python
	pip install --target=python -r "${INPUT_REQUIREMENTS_TXT}"
	zip -r dependencies.zip ./python
}

publish_dependencies_as_layer(){
	echo "Publishing dependencies as a layer..."
	local result=$(aws lambda publish-layer-version --layer-name "${INPUT_LAMBDA_LAYER_ARN}" --zip-file fileb://dependencies.zip)
	LAYER_VERSION=$(jq '.Version' <<< "$result")
	rm -rf python
	rm dependencies.zip
}

publish_function_code(){
	echo "Deploying the code itself..."
	zip -r code.zip . -x \*.git\*
	aws lambda update-function-code --function-name "${INPUT_LAMBDA_FUNCTION_NAME}" --zip-file fileb://code.zip
	aws lambda wait function-updated --function-name "${INPUT_LAMBDA_FUNCTION_NAME}"
}

update_function_layers(){
	echo "Using the layer in the function..."
	aws lambda update-function-configuration --function-name "${INPUT_LAMBDA_FUNCTION_NAME}" --layers "${INPUT_LAMBDA_LAYER_ARN}:${LAYER_VERSION}"
}

deploy_lambda_function(){

	requirements_lengh=$(wc -c ${INPUT_REQUIREMENTS_TXT})
	if [$requirements_lengh -lt 2]
	then
	 echo "No requirements on file"
	if
	
	if [$requirements_lengh -gt 2]
	then
	 install_zip_dependencies
	 publish_dependencies_as_layer
	fi
	
	publish_function_code
	
	if [$requirements_lengh -gt 2]
	then
	 update_function_layers
	fi
}	

deploy_lambda_function
echo "Done."
