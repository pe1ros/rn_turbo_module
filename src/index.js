// @flow
import { NativeModules } from 'react-native'

const isTurboModuleEnabled = global.__turboModuleProxy != null;

const calculator = isTurboModuleEnabled ?
  require("./NativeCalculator").default :
  NativeModules.Calculator;

const stringBuilder = isTurboModuleEnabled ?
  require("./NativeStringBuilder").default :
  NativeModules.StringBuilder;

export {calculator, stringBuilder};
