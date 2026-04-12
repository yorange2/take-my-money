#!/usr/bin/env node
import { greet, add } from '@take-my-money/shared-lib';

console.log(greet('World'));
console.log(`2 + 3 = ${add(2, 3)}`);
