const brain = require('brain.js');
const fs = require('fs');

//const fn = require('./nn1.txt');

let files = fs.readdirSync('./');
let datasets = files.filter(file => file.match(/^dataset.*json$/));

function verify(level){
    let samples = [];

    datasets.forEach(dataset => {
        let data = fs.readFileSync(dataset);
        let parsed = JSON.parse(data);
        parsed.samples.forEach(sample => {
            let output = sample.o > level ? 1.0 : 0.0;
            let input = sample.f;

            input.push(sample.p)

            samples.push({
                //input: input,
                input: input.slice(0).map(x => x + Math.random() / 5),
                output: [output]
            })
        })
    })

    let nn = JSON.parse(fs.readFileSync('nn' + parseInt(level) + '.json'));

    function calculate(input) {
        let offset = 0;
        let result = input.slice(0);

        for(k in nn.layers) {
            let layerSize = nn.layers[k];
            let countOfWeights = layerSize * (result.length + 1)
            result = calculateLayer(result, nn.weights.slice(offset, offset + countOfWeights))
            offset += countOfWeights
        }

        return result[0]
    }

    function calculateLayer(input, weights) {
        let step = 1 + input.length
        let count = weights.length / step
        let result = []

        for (i = 0; i<count; i++) {
            result[i] = weights[i*step]

            for (k in input) {
                let j = parseInt(k)
                let w = weights[i*step + j + 1]
                result[i] += input[j] * weights[i*step + j + 1]
            }
        }

        return result.map(x => 1 / (Math.exp(-x) + 1))
    }

    var errors = 0;
    samples.forEach(s => {
        let r1 = calculate(s.input);
        //let r2 = fn(s.input);
        if((r1 > 0.5) != (s.output[0] > 0.5)) errors++;
    })

    console.log('count', samples.length)
    console.log("errors:", errors / samples.length)
}

[1.5, 2.5, 3.5].forEach(verify);
