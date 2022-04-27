// @flow
import type { TurboModule } from 'react-native/Libraries/TurboModule/RCTExport';
import { TurboModuleRegistry } from 'react-native';

export interface Spec extends TurboModule {
  getNewString(str: string): Promise<string>;
}

export default (TurboModuleRegistry.get<Spec>(
'StringBuilder'
): ?Spec);
