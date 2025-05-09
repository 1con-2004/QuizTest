/// <reference types="react" />
/// <reference types="react-dom" />
/// <reference types="vite/client" />

declare module '*.scss' {
  const content: { [className: string]: string };
  export default content;
}

declare module '*.css' {
  const content: { [className: string]: string };
  export default content;
}

declare module '*.svg' {
  import * as React from 'react';
  export const ReactComponent: React.FunctionComponent<React.SVGProps<SVGSVGElement>>;
  const src: string;
  export default src;
}

declare module '*.png';
declare module '*.jpg';
declare module '*.jpeg';
declare module '*.gif'; 