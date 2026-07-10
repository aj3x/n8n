import { FeatureReturnType, LicenseProvider } from './types';

export class CrackedLicenseProvider implements LicenseProvider {
  // Simulate that all features are enabled
  isLicensed(feature: string): true {
    return true;
  }
  getValue<T extends keyof FeatureReturnType>(feature: T): FeatureReturnType[T] {
    const defaultValues: FeatureReturnType = {
      'planName': 'Community',
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