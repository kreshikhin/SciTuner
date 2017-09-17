const brain = require('brain.js');
const fs = require('fs');

let files = fs.readdirSync('./');
let datasets = files.filter(file => file.match(/^dataset.*json$/));

function train(level){
    let samples = [];
    let net = new brain.NeuralNetwork();

    datasets.forEach(dataset => {
        let data = fs.readFileSync(dataset);
        let parsed = JSON.parse(data);
        parsed.samples.forEach(sample => {
            let output = sample.o > level ? 1.0 : 0.0;
            let input = sample.f;

            input.push(sample.p)

            samples.push({
                input: input,
                output: [output]
            })
        })
    })

    net.train(samples, {
      errorThresh: 0.0001,  // error threshold to reach
      iterations: 10000,   // maximum training iterations
      log: true,           // console.log() progress periodically
      logPeriod: 500,       // number of iterations between logging
      learningRate: 0.3    // learning rate
    })


    var errors = 0;
    samples.forEach(s => {
        let r = net.run(s.input);
        if((r[0] > 0.5) != (s.output[0] > 0.5)) errors++;
    })

    console.log('count', samples.length)
    console.log("errors:", errors / samples.length)

    let dump = net.toJSON();
    let layers = dump.layers.slice(1).map(l => Object.keys(l).length)

    let weights = []
    dump.layers.slice(1).forEach(l => {
        let keys = Object.keys(l).sort((a, b) => a - b)
        console.log(keys);

        keys.forEach(key => {
            let n = l[key];
            weights.push(n.bias);

            let indexes = Object.keys(n.weights).sort((a, b) => a - b)
            console.log(indexes);

            indexes.forEach(index => {
                weights.push(n.weights[index]);
            })
        })
    })

    fs.writeFileSync('_nn' + parseInt(level) + '.json', JSON.stringify(net.toJSON(), null, 2))
    fs.writeFileSync('nn' + parseInt(level) + '.txt', net.toFunction().toString())

    fs.writeFileSync('nn' + parseInt(level) + '.json', JSON.stringify({
        layers: layers,
        weights: weights
    }, null, 2))

    //console.log(net.toFunction().toString())
}

[1.5].forEach(train);
//[1.5, 2.5, 3.5].forEach(train);
