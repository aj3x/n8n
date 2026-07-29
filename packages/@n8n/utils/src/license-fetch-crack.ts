type LicenseRequest =
	| {
			request: 'getFeatureValue' | 'hasFeatureEnabled';
			feature: string;
	  }
	| { request: 'getLicense' };

const version = '1.0';

type LicenseResponse = {
	enabledFeatures: Record<string, boolean>;
	featureValues: Record<string, number | string>;
};

export class LicenseFetcherCracked {
	async _fetch({ request, feature }: LicenseRequest) {
		const url = process.env.N8N_LICENSE_FETCHER_URL;
		if (!url) {
			this._cert = offlineCert;
			return offlineCert;
		}

		const res = await fetch(url, {
			method: 'POST',
			body: JSON.stringify({ version, request, feature }),
		});
		const data = await res.json();
		return data;
	}
	_initializationPromise: Promise<void> | null = null;
	_cert: LicenseResponse | undefined = undefined;
	_certPromise: Promise<any> | null = null;
	_lastFetchTime = 0;
	_fetchInterval = 60 * 1000; // 1 minute
	_refreshCallback: NodeJS.Timeout | null = null;

	async initialize() {
		if (this._initializationPromise) return;
		this._initializationPromise = this.getLicense();
		await this._initializationPromise;
		this.setupRefreshInterval();
	}

	setupRefreshInterval() {
		if (this._refreshCallback) return;
		this._refreshCallback = setInterval(() => {
			this.getLicense();
		}, this._fetchInterval);
	}

	async _reset() {
		if (this._refreshCallback) {
			clearInterval(this._refreshCallback);
			this._refreshCallback = null;
		}
		this._lastFetchTime = 0;
		this.setupRefreshInterval();
	}

	reload() {
		this.getLicense();
		this._reset();
	}

	renew() {
		this.getLicense();
		this._reset();
	}

	async getLicense(force = false) {
		if (!force && this._cert && Date.now() - this._lastFetchTime < this._fetchInterval) {
			return this._cert;
		}
		if (!force && this._certPromise) {
			return this._certPromise;
		}
		this._lastFetchTime = Date.now();
		this._certPromise = this._fetch({ request: 'getLicense' });
		this._cert = await this._certPromise;
		return this._cert;
	}

	hasFeatureEnabled(feature: BooleanLicenseFeature): boolean {
		return this._cert?.enabledFeatures[feature];
	}
	getFeatureValue<T extends keyof FeatureReturnType>(feature: T): FeatureReturnType[T] {
		return this._cert?.featureValues[feature] as FeatureReturnType[T];
	}
}

const offlineCert = {
	enabledFeatures: {
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
	},
	featureValues: {
		planName: 'Community',
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
	},
};
