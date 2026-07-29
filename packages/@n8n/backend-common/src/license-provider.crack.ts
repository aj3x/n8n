import { FeatureReturnType, LicenseProvider } from './types';
import type { BooleanLicenseFeature } from '@n8n/constants';
import { LicenseFetcherCracked } from '@n8n/utils/license-fetch-crack';
export class CrackedLicenseProvider implements LicenseProvider {
	private licenseFetcher: LicenseFetcherCracked;

	constructor() {
		this.licenseFetcher = new LicenseFetcherCracked();
		this.licenseFetcher.initialize();
	}

	isLicensed(feature: BooleanLicenseFeature): boolean {
		return this.licenseFetcher.hasFeatureEnabled(feature);
	}
	getValue<T extends keyof FeatureReturnType>(feature: T): FeatureReturnType[T] {
		return this.licenseFetcher.getFeatureValue(feature);
	}
}
