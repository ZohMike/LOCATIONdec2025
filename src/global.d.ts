
interface Window {
  gapi: {
    load: (api: string, callback: () => void) => void;
    client: {
      init: (config: any) => Promise<void>;
      load: (api: string, version: string) => Promise<void>;
      people: {
        people: {
          connections: {
            list: (params: any) => Promise<any>;
          };
        };
      };
    };
    auth2: {
      getAuthInstance: () => any;
      init: (params: any) => any;
    };
  };
  google: {
    accounts: {
      id: any;
      oauth2: {
        initTokenClient: (config: any) => any;
      };
    };
  };
}
