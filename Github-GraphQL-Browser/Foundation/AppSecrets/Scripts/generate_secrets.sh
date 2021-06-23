# Generate list of arguments to pass to Sourcery
function sourceryArguments {
  # Environment variables from Base.xcconfig to map into AppSecrets
  local arguments=(
    "API_URL"
    "API_TOKEN"
  )
  local combinedArgs

  local argumentsIndices=${!arguments[*]}
  for index in $argumentsIndices
  do
    # Make the arguments list comma-separated
    if [ $index -gt 0 ];
    then
      combinedArgs="${combinedArgs},"
    fi

    # Append the argument name and escaped argument value
    local argument=${arguments[$index]}
    local argumentName="${argument}"
    local argumentValue="\"${!argument}\""
    local argumentPair="${argumentName}=${argumentValue}"
    combinedArgs="${combinedArgs}${argumentPair}"
  done
  echo $combinedArgs
}

sourceryArgs=$(sourceryArguments)

.sourcery-bin/bin/sourcery \
    --sources SupportingFiles/Configuration \
    --templates Sourcery/Templates/AppSecrets.stencil \
    --output SupportingFiles/Generated \
    --args $sourceryArgs
