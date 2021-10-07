```js
// mockupDB.js


export default {
    key1: "value1",
    key2: "value2",
    key3: "value3"
}
```

Command.js

```js
// Command.js

import mockupDB from "./mockupDB";


class Command {

    constructor(execute, undo, serialize, value) {
        this.execute = execute;
        this.undo = undo;
        this.serialize = serialize;
        this.value = value;
    }

}



export function UpdateCommand(key, value) {

    let oldValue;

    const execute = () => {
        if (mockupDB.hasOwnProperty(key)) {
            oldValue = mockupDB[key];
            mockupDB[key] = value;
        }
    };

    const undo = () => {
        if (oldValue) {
            mockupDB[key] = oldValue;
        }
    };

    const serialize = () => {
        return JSON.stringify({type: "Command", action: "update", key: key, value: value});
    };

    return new Command(execute, undo, serialize, value);
}


export function DeleteCommand(key) {

    let oldValue;

    const execute = () => {
        if (mockupDB.hasOwnProperty(key)) {
            oldValue = mockupDB[key];
            delete mockupDB[key];
        }
    };

    const undo = () => {
        mockupDB[key] = oldValue;
    };

    const serialize = () => {
        return JSON.stringify({type: "Command", action: "delete", key: key});
    };

    return new Command(execute, undo, serialize);
}
```

CommandManager.js

```js
// CommandManager.js

export class CommandManager {

    constructor() {
        this.executeHistory = [];
        this.undoHistory = [];
    }

    execute(command) {
        this.executeHistory.push(command);
        command.execute();
        console.log(`Executed command ${command.serialize()}`);
    }

    undo() {
        let command = this.executeHistory.pop();
        if (command) {
            this.undoHistory.push(command);
            command.undo();
            console.log(`Undo command ${command.serialize()}`)
        }
    }

    redo() {
        let command = this.undoHistory.pop();
        if (command) {
            this.executeHistory.push(command);
            command.execute();
            console.log(`Redo command ${command.serialize()}`);
        }
    }
}
```

client.js

```js
// client.js

import {CommandManager} from "./CommandManager";
import {UpdateCommand, DeleteCommand} from "./Command";
import mockupDB from "./mockupDB";

"use strict";

const main = () => {

    const commandManager = new CommandManager();

    console.log("DB status", mockupDB, "\n");
    commandManager.execute(new UpdateCommand("key2", "newValue2"));
    commandManager.execute(new DeleteCommand("key3"));
    console.log("DB status", mockupDB, "\n");
    commandManager.undo();
    commandManager.undo();
    console.log("DB status", mockupDB, "\n");
    commandManager.redo();
    commandManager.redo();
    console.log("DB status", mockupDB, "\n");

};

main();
```

output

```js
DB status { key1: 'value1', key2: 'value2', key3: 'value3' }

Executed command {"type":"Command","action":"update","key":"key2","value":"newValue2"}
Executed command {"type":"Command","action":"delete","key":"key3"}
DB status { key1: 'value1', key2: 'newValue2' }

Undo command {"type":"Command","action":"delete","key":"key3"}
Undo command {"type":"Command","action":"update","key":"key2","value":"newValue2"}
DB status { key1: 'value1', key2: 'value2', key3: 'value3' }

Redo command {"type":"Command","action":"update","key":"key2","value":"newValue2"}
Redo command {"type":"Command","action":"delete","key":"key3"}
DB status { key1: 'value1', key2: 'newValue2' }
```

[javascript](https://stackoverflow.com/questions/tagged/javascript) [design-patterns](https://stackoverflow.com/questions/tagged/design-patterns) [ecmascript-6](https://stackoverflow.com/questions/tagged/ecmascript-6) [command](https://stackoverflow.com/questions/tagged/command)