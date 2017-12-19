const TEST = "data/testfile.json";
const SMALLSQL = "data/smallsql2.json";

const TYPE_1 = "type-1";

// Load json file
loadVisualization(SMALLSQL);

//Inspiration
//https://stackoverflow.com/questions/22873374/search-functionality-for-d3-bundle-layout


function loadVisualization(jsonFile) {
    // Read data file and initialize
    d3.json(jsonFile, (error, data) => {
        if (error) throw error;
        initializeDiagram(data.files, data.clone_pairs);
    });
}

function getClonePairsForFile(filename, clonePairs) {
    return clonePairs
        .filter(clonePair =>
            clonePair.origin.file === filename || clonePair.clone.file === filename)
        .map(clonePair => clonePair);
}

function getOriginFiles(files, clonePairs) {
    const originNames = clonePairs.map(clonePair => clonePair.origin.file);
    return files
        .filter(file => originNames.indexOf(file.name) !== -1)
        .map(file => file);
}

function initializeDiagram(allFiles, allClonePairs) {
    const type1Clones = allClonePairs
        .filter(clonePair => clonePair.clone_type === TYPE_1)
        .reduce((prev, clonePair) => prev + 1, 0);
    var diameter = 800;
    if (totalClones > 1000) {
        diameter = 800 * 1.8;
    }
    const radius = diameter / 2;
    const innerRadius = radius - 120;
    // Create the base circle
    const cluster = d3.layout.cluster()
        .size([360, innerRadius])
        .sort(null)
        .value(d => d.size);
    const bundle = d3.layout.bundle();
    const line = d3.svg.line.radial()
        .interpolate("bundle")
        .tension(.85)
        .radius(d => d.y)
        .angle(d => d.x / 180 * Math.PI);
    // Define svg
    const svg = d3.select("#diagram").append("svg")
        .attr("width", diameter * 1.2)
        .attr("height", diameter * 1.2)
        .append("g")
        .attr("transform", "translate(" + radius + "," + radius + ")");
    var link = svg.append("g").selectAll(".link");
    var linkCircle = svg.append("g").selectAll("circle.link");
    var node = svg.append("g").selectAll(".node");
    // nodes and links
    var nodes = cluster.nodes(getFileHierarchy(allFiles, allClonePairs)),
        links = getFileClonePairs(nodes, allClonePairs);
    links = links.filter(link => link.target !== undefined);
    // constrcut links in nodes
    link = link
        .data(bundle(links))
        .enter().append("path")
        .each(d => {
            d.source = d[0];
            d.target = d[d.length - 1];
        })
        .attr("class", "link")
        .attr("d", line);
    // self pointing link
    var linkCircles = links.filter(l => l.source.key === l.target.key);
    linkCircle = linkCircle
        .data(linkCircles, d => d.target.key)
        .enter().insert("svg:line", ".link")
        .attr("class", "link")
        .attr("rx", d => 17)
        .attr("ry", d => 7)
        .attr("class", "self-link")

    // Create nodes
    node = node
        .data(nodes.filter(n => !n.children))
        .enter().append("text")
        .attr("class", "node")
        .attr("dy", ".31em")
        .attr("transform", d => "rotate(" + (d.x - 90) + ")translate(" + (d.y + 8) + ",0)" + (d.x < 180 ? "" : "rotate(180)"))
        .style("text-anchor", d => d.x < 180 ? "start" : "end")
        .text(d => (d.key).split(".")[0])
        .on("mouseover", mouseovered(allFiles, allClonePairs))
        .on("mousedown", mousedown(allFiles, allClonePairs))
        .on("mouseout", mouseouted(allFiles, allClonePairs));
    var selectedPair;
    // Set files as nodes
    function getFileHierarchy(files, clonePairs) {
        var map = {};
        const find = (name, data) => {
            var node = map[name],
                i;
            if (!node) {
                node = map[name] = data || { name: name, children: [] };
                if (name.length) {
                    node.parent = find(name.substring(0, i = name));
                    node.parent.children.push(node);
                    // set it's name as key
                    node.key = name.substring(i + 1);
                    // Add node's clone pair
                    node.clonePairs = clonePairs
                        .filter(clonepair => clonepair.origin.file == node.name)
                        .map(clonepair => clonepair);
                }
            }
            return node;
        }
        files.forEach(d => find(d.name, d));
        return map[""];
    }
    // Get clone pairs
    function getFileClonePairs(nodes, clonePairs) {
        var map = {},
            clones = [];
        nodes.forEach(d => map[d.name] = d);
        nodes.forEach(node => {
            clonePairs
                    //retrieve correct json
                    .filter(clonepair => node.name === clonepair.origin.file ||
                    node.name === clonepair.clone.file)
                .forEach(clonePair => {
                    const cloneFile = clonePair.origin.file === node.name ?
                        clonePair.clone.file : clonePair.origin.file;
                    clones.push({
                        source: map[node.name],
                        target: map[cloneFile]
                    });
                });
        });
        return clones;
    }
    GNode = node;
    d3.select(self.frameElement).style("height", diameter + "px");
}