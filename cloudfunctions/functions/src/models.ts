export class DBPrefix {
    static users: string = 'users';
    static posted: string = 'posted';
    static received: string = 'received';
    static activate: string = 'activate';
    static conversation: string = 'conversation';
    static replys: string = 'replys';

    static reports: string = 'reports';

    static activeId: string = 'ddropactivateusersdocumentid';
} 

export interface User {
    id: string,
    name: string,
    img: string,
    bgImage: string,
    profile: string,
    lang: string,
    age: number,
    available: boolean,
    timestamp: number,
    notification: boolean,
    active: boolean,
    token: string,
    refusal: string[]
}

export interface Message {
    id: string,
    img: string,
    imgReg: boolean,
    file: string,
    message: string,
    uid: string,
    timestamp: number,
    from: User    
}

export interface Reply {
    id: string,
    message: string,
    img: string,
    from: User,
    timestamp: number,
    tmp: boolean,
    read: boolean,
    to: string
}