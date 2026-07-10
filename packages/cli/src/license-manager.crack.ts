import { FeatureReturnType } from './license';
import { LICENSE_FEATURES } from '@n8n/constants';
import type { BooleanLicenseFeature } from '@n8n/constants';

export class LicenseManagerCracked {
	hasFeatureEnabled(feature: BooleanLicenseFeature): boolean {
		// Disable feature for displaing the license warning message in the UI
		if (feature === LICENSE_FEATURES.SHOW_NON_PROD_BANNER) {
			return false;
		}
		return true;
	}

	getFeatureValue<T extends keyof FeatureReturnType>(feature: T): FeatureReturnType[T] {
		const defaultValues: FeatureReturnType = {
			planName: 'Community',
			'quota:users': -1,
			'quota:activeWorkflows': -1,
			'quota:maxVariables': -1,
			'quota:aiCredits': 0,
			'quota:workflowHistoryPrune': 7,
			'quota:insights:maxHistoryDays': 7,
			'quota:insights:retention:maxAgeDays': 180,
			'quota:insights:retention:pruneIntervalDays': 24,
			'quota:maxTeamProjects': -1,
			'quota:evaluations:maxWorkflows': -1,
		};
		return defaultValues[feature] as FeatureReturnType[T];
	}
}
