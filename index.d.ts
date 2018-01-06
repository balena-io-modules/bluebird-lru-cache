import * as Promise from 'bluebird';
import TypedError = require('typed-error');

declare module 'bluebird-lru-cache' {

	export class NoSuchKeyError extends TypedError {
		public constructor(
			public key: string,
		) {
			super();
		}
	}

	export interface Options {
		max: number;
		maxAge: number;
		length: (n: any) => number;
		dispose: (key: any, value: any) => any;
		stale: boolean;
		noreject: boolean;
		fetchFn: (key: any) => any;
	}

	export default class BluebirdLRU {

		public constructor(options: Options);

		public set(key: any, value: any, max?: number): Promise<boolean>;
		public get(key: any): Promise<any>;
		public peek(key: any): Promise<any>;
		public del(key: any): Promise<undefined>;
		public reset(): Promise<undefined>;
		public has(key: any): Promise<boolean>;
		public forEach(fn: (value: any, key: any: cache: any) => void, thisp?: any): void;
		public keys(): Promise<any[]>;
		public values(): Promise<any[]>;
		public length(): number;
		public itemCount(): number;
	}
}
