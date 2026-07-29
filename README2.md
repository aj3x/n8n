If you want to customize feature values add this to your env
```env
N8N_LICENSE_FETCHER_URL=
```
host that to an endpoint that returns something like below

```js
const enabledFeatures = {
	'feat:sharing': true,
	'feat:ldap': true,
	'feat:saml': true,
	'feat:oidc': true,
	'feat:mfaEnforcement': true,
	'feat:logStreaming': true,
	'feat:advancedExecutionFilters': true,
	'feat:variables': true,
	'feat:sourceControl': true,
	'feat:apiDisabled': false,
	'feat:externalSecrets': true,
	'feat:showNonProdBanner': false,
	'feat:debugInEditor': true,
	'feat:binaryDataS3': true,
	'feat:binaryDataAz': true,
	'feat:executionDataS3': true,
	'feat:executionDataAz': true,
	'feat:multipleMainInstances': true,
	'feat:workerView': true,
	'feat:advancedPermissions': true,
	'feat:projectRole:admin': true,
	'feat:projectRole:editor': true,
	'feat:projectRole:viewer': true,
	'feat:aiAssistant': true,
	'feat:askAi': true,
	'feat:communityNodes:customRegistry': true,
	'feat:aiCredits': true,
	'feat:aiGateway': true,
	'feat:folders': true,
	'feat:insights:viewSummary': true,
	'feat:insights:viewDashboard': true,
	'feat:insights:viewHourlyData': true,
	'feat:apiKeyScopes': true,
	'feat:workflowDiffs': true,
	'feat:namedVersions': true,
	'feat:customRoles': true,
	'feat:aiBuilder': true,
	'feat:dynamicCredentials': true,
	'feat:personalSpacePolicy': true,
	'feat:tokenExchange': true,
	'feat:dataRedaction': true,
	'feat:otel:customSpanAttributes': true,
	'feat:workflowReviews': true,
}

const featureValues = {
    'planName': "Community",
    'quota:users': -1,
    'quota:activeWorkflows': -1,
    'quota:maxVariables': -1,
    'quota:aiCredits': 0,
    'quota:workflowHistoryPrune': -1,
    'quota:insights:maxHistoryDays': -1,
    'quota:insights:retention:maxAgeDays': -1,
    'quota:insights:retention:pruneIntervalDays': -1,
    'quota:maxTeamProjects': -1,
    'quota:evaluations:maxWorkflows': -1,
}

export const handler = async (event) => {
  const response = {
    statusCode: 200,
    body: JSON.stringify({
      enabledFeatures,
      featureValues,
    }),
  };
  return response;
};
```
