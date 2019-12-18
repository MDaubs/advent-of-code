import fs = require('fs');
import readline = require('readline');

type ModuleMass = number;
type FuelVolume = number;
type ModuleMassToFuelVolumeConverter = (mass: ModuleMass) => FuelVolume;

const FILENAME = 'day1.input';

function accumulateInputs(filename: string, callback: ModuleMassToFuelVolumeConverter) {
    return new Promise<number>(resolve => {
        const reader = readline.createInterface({
            input: fs.createReadStream(filename),
            output: process.stdout
        })

        let accumulatedValue = 0;

        reader.on('line', (line: string) => { accumulatedValue += callback(parseInt(line)); });
        reader.on('close', () => resolve(accumulatedValue));
    });
}

accumulateInputs(FILENAME, (mass: ModuleMass) => Math.floor(mass / 3) - 2).then(console.log);