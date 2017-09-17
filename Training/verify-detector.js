const brain = require('brain.js');
const fs = require('fs');

let files = fs.readdirSync('./');
let datasets = files.filter(file => file.match(/^dataset.*json$/));

function Network(level) {
    let nn = JSON.parse(fs.readFileSync('nn' + parseInt(level) + '.json'));

    this.calculate = function(input) {
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
}

function Detector(){
    let networks = [];

    [1.5, 2.5, 3.5].forEach(level => {
        networks.push(new Network(level))
    });

    this.detect = function(input){
        for(var k = 0; k < networks.length; k++){
            let network = networks[k];

            if(network.calculate(input) < 0.5) {
                return k + 1;
            }
        }

        return 4;
    }
}

function verify(level){
    let detector = new Detector();

    let samples = [];

    datasets.forEach(dataset => {
        let data = fs.readFileSync(dataset);
        let parsed = JSON.parse(data);
        parsed.samples.forEach(sample => {
            let input = sample.f;

            input.push(sample.p)

            samples.push({
                input: input,
                output: sample.o
            })
        })
    })

    var errors = 0;
    samples.forEach(s => {
        let r = detector.detect(s.input);
        console.log(r, s.output);
        if(r != s.output) errors++;
    })

    console.log('count', samples.length)
    console.log("errors:", errors / samples.length)
}

verify()
