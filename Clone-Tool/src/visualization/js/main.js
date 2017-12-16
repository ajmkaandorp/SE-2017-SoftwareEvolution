const SMALLSQL_RESULTS_FILE = "data/results_smallsql.json?" + Math.random();

const DIAMETER = 800;
const DEGREES = 360;
const TENSION = .85;
const ELLIPSE_RAD_X = 17;
const ELLIPSE_RAD_Y = 7;

const TYPE_1 = "type-1";
const TYPE_2 = "type-2";

const HIGHLIGHT_ON_MOUSEOVER = false;
const KEEP_SELECTED_HIGHLIGHT = false;



// Start by loading small sql
loadVisualization("data/results_smallsql.json");

var GLClearHighlightFromDiagram = () => {};
var GLSetupHighlightOnDiagram = (b, c) => {};
var GNode = {};

function getFirstClonePairFromFile(filename, node) {
    return node[0].filter(n => n.__data__.key === filename)[0].__data__;
}

function clearData() {
    $("#diagram").empty();

    // Clear clone view
    $('#clone-view-table tbody > tr').remove();
    $('#code-detail-view-origin').text("");
    $('#code-detail-view-clone').text("");
    $('#code-detail-view #rhs').text("");
    $('#code-detail-view #lhs').text("");
}

function loadVisualization(resultsFile) {
    clearData();
    // Read json and initialize page
    d3.json(resultsFile, (error, data) => {
        if (error) throw error;
        initializeDiagram(data.files, data.clone_pairs);
        initializeViews(data.summary, data.files, data.clone_pairs);
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

function initializeViews(summary, allFiles, allClonePairs) {
    $(document).ready(() => {
        initializeSummaries(summary, allClonePairs);
        initializeFileView(allFiles, allClonePairs);
    });
}

function initializeSummaries(summary, allClonePairs) {
    $('#page-header').text(summary.project_name);

    const type1Clones = allClonePairs
        .filter(clonePair => clonePair.clone_type === TYPE_1)
        .reduce((prev, clonePair) => prev + 1, 0);

    const type2Clones = allClonePairs
        .filter(clonePair => clonePair.clone_type === TYPE_2)
        .reduce((prev, clonePair) => prev + 1, 0);

    const totalClones = type1Clones + type2Clones;

    const summaryStats =
        "<tr>\
              <th scope=\"row\">Type-1 Clones</th>\
              <td>" + type1Clones + "</td>\
            </tr>\
            <tr>\
              <th scope=\"row\">Type-2 Clones</th>\
              <td>" + type2Clones + "</td>\
            </tr>\
                    <tr>\
              <th scope=\"row\">Total Clones</th>\
              <td>" + totalClones + "</td>\
            </tr>";

    $('#summary-table').append(summaryStats);
}

function initializeFileView(allFiles, allClonePairs) {
    const fileViewTable = $('#file-view-table');

    // populate file view with the files
    var lineCounter = 1;
    // Get files that are in the origin part of the clone pair
    allFiles
        .forEach(file => {
            const cloneNum = getClonePairsForFile(file.name, allClonePairs).length;

            const rowId = "file-view-row-" + file.name.substring(0, i = file.name.lastIndexOf("."));
            const tr =
                "<tr id=" + rowId + ">\
                <td>" + lineCounter + "</td>\
                <td>" + file.dir + "/" + file.name + "</td>\
                <td>" + cloneNum + "</td>\
              </tr>";
            fileViewTable.append(tr);

            // row on click
            $("#" + rowId).on('click', () => {
                $("#" + rowId).siblings().removeClass("info");
                $("#" + rowId).addClass("info");

                GLClearHighlightFromDiagram();
                GLSetupHighlightOnDiagram(
                    getFirstClonePairFromFile(file.name, GNode),
                    allClonePairs);

                initializeCloneView(file, allClonePairs);
            });

            lineCounter++;
        });
}


//TODO: Finish clones-in-file view

function initializeCloneView(origin, allClonePairs) {

    // Clear table first
    $('#clone-view-table tbody > tr').remove();
    $('#code-detail-view-origin').text("");
    $('#code-detail-view-clone').text("");
    $('#code-detail-view #lhs').text("");
    $('#code-detail-view #rhs').text("");

    const cloneViewTable = $('#clone-view-table');
    // keep first clonePair in order to show it on the code view.
    var isFirstClonePairPicked = false;
    var firstClonePair = null;

    // Get clone pairs that have origin the given file
    allClonePairs
        .filter(clonePair =>
            clonePair.origin.file === origin.name || clonePair.clone.file === origin.name)
        .forEach(clonePair => {
            if (!isFirstClonePairPicked) {
                firstClonePair = clonePair;
                isFirstClonePairPicked = true;
            }

            const rowId = "clone-view-row" + lineCounter;
            var trClass = "";

            const cloneFile = clonePair.origin.file === origin.name ? clonePair.clone.file : clonePair.origin.file;
            const tr =
                "<tr class=" + trClass + " id=" + rowId + ">\
                      <td>" + cloneFile + "</td>\
                      <td>" + clonePair.clone_type + "</td>\
                     </tr>";
            cloneViewTable.append(tr);

            // row on click
            $("#" + rowId).on('click', () => {
                showClonesInCodeView(clonePair);
            });

            lineCounter++;
        });
    showClonesInCodeView(firstClonePair);
}



//TODO FINISH EXACT CLONE VIEW

function showClonesInCodeView(clonePair) {
    const originSourceCode = clonePair.origin.source_code;
    const cloneSourceCode = clonePair.clone.source_code;

    const originFilename = clonePair.origin.file;
    const originStartLine = clonePair.origin.start_line;
    const originEndLine = clonePair.origin.end_line;

    const cloneFilename = clonePair.clone.file;
    const cloneStartLine = clonePair.clone.start_line;
    const cloneEndLine = clonePair.clone.end_line;

    $('#code-detail-view #lhs').text(originSourceCode);
    $('#code-detail-view #rhs').text(cloneSourceCode);

    // Show lines which include the clones
    $('#code-detail-view-origin')
        .text(originFilename + ": <" + originStartLine + ", " + originEndLine + ">");

    $('#code-detail-view-clone')
        .text(cloneFilename + ": <" + cloneStartLine + ", " + cloneEndLine + ">");
}

function initializeDiagram(allFiles, allClonePairs) {

    // Get number of clones
    const type1Clones = allClonePairs
        .filter(clonePair => clonePair.clone_type === TYPE_1)
        .reduce((prev, clonePair) => prev + 1, 0);

    const type2Clones = allClonePairs
        .filter(clonePair => clonePair.clone_type === TYPE_2)
        .reduce((prev, clonePair) => prev + 1, 0);

    const totalClones = type1Clones + type2Clones;

    var diameter = DIAMETER;
    if (totalClones > 1000) {
        diameter = DIAMETER * 1.8;
    }

    const radius = diameter / 2;
    const innerRadius = radius - 120;

    // Make a full circle
    const cluster = d3.layout.cluster()
        .size([DEGREES, innerRadius])
        .sort(null)
        .value(d => d.size);

    const bundle = d3.layout.bundle();

    const line = d3.svg.line.radial()
        .interpolate("bundle")
        .tension(TENSION)
        .radius(d => d.y)
        .angle(d => d.x / 180 * Math.PI);

    // Setup dom elements
    const svg = d3.select("#diagram").append("svg")
        .attr("width", diameter * 1.2)
        .attr("height", diameter * 1.2)
        .append("g")
        .attr("transform", "translate(" + radius + "," + radius + ")");

    var link = svg.append("g").selectAll(".link"),
        linkCircle = svg.append("g").selectAll("circle.link"),
        node = svg.append("g").selectAll(".node");

    // Setup nodes and links from the data
    var nodes = cluster.nodes(getFileHierarchy(allFiles, allClonePairs)),
        links = getFileClonePairs(nodes, allClonePairs);

    links = links.filter(link => link.target !== undefined);

    // Construct the links between the nodes in the dom
    link = link
        .data(bundle(links))
        .enter().append("path")
        .each(d => {
            d.source = d[0];
            d.target = d[d.length - 1];
        })
        .attr("class", "link")
        .attr("d", line);

    // Construct the nodes in the dom
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

    // Keep state of selected pair on diagram
    var selectedPair;

    // Lazily construct the files as nodes.
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

    // Return a list of clone pairs for the array of clone pairs.
    function getFileClonePairs(nodes, clonePairs) {
        var map = {},
            clones = [];

        // Create a map from name to node.
        nodes.forEach(d => map[d.name] = d);

        nodes.forEach(node => {
            clonePairs

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

    function mousedown(allFiles, allClonePairs) {
        return function(d) {
            var index = 0;
            allFiles
                .filter(file => file.name === d.key)
                .forEach(file => {

                    // highlight file on view
                    const fileViewRowId = "#file-view-row-" + file.name.substring(0, i = file.name.lastIndexOf("."));
                    $(fileViewRowId).siblings().removeClass("info")
                    $(fileViewRowId).addClass("info");

                    initializeCloneView(file, allClonePairs);

                    selectedPair = d;
                    clearHighlightFromDiagram();
                    setupHighlightOnDiagram(selectedPair, allClonePairs);

                    index++;
                });
        }
    }

    function mouseovered(allFiles, allClonePairs) {
        return function(d) {

            if (HIGHLIGHT_ON_MOUSEOVER) {
                // Clear clone view
                $('#clone-view-table tbody > tr').remove();
                $('#code-detail-view-origin').text("");
                $('#code-detail-view-clone').text("");

                allFiles
                    .filter(file => file.name === d.key)
                    .forEach(file => {
                        // highlight file on fileview
                        const fileViewRowId = "#file-view-row-" + file.name.substring(0, i = file.name.lastIndexOf("."));
                        $(fileViewRowId).siblings().removeClass("info")
                        $(fileViewRowId).addClass("info");

                        initializeCloneView(file, allClonePairs);
                    });
            }
        }
    }

    function mouseouted(allFiles, allClonePairs) {
        return function(d) {
            if (KEEP_SELECTED_HIGHLIGHT && selectedPair !== undefined) {
                setupHighlightOnDiagram(d, allClonePairs);
            }

            if (HIGHLIGHT_ON_MOUSEOVER) {
                const fileViewRowId = "#file-view-row-" + d.key.substring(0, i = d.key.lastIndexOf("."));
                $(fileViewRowId).siblings().removeClass("info")
                $(fileViewRowId).addClass("info");
            }
        }
    }

    const clearHighlightFromDiagram = () => {

        // Remove highlight from diagram
        link
            .classed("link--target", false)
            .classed("link--source", false)
            .classed("link--clone-type-1", false)
            .classed("link--clone-type-2", false)

        linkCircle
            .classed("link--target", false)
            .classed("link--source", false)
            .classed("link--clone-type-1", false)
            .classed("link--clone-type-2", false)

        node
            .classed("node--target", false)
            .classed("node--source", false);
    }

    const setupHighlightOnDiagram = (d, allClonePairs) => {

        var linkCls = "link--target";

        getClonePairsForFile(d.key, allClonePairs)
            .filter(clonePair => clonePair.clone_type === TYPE_2)
            .forEach(() => linkCls = "link--clone-type-2");

        getClonePairsForFile(d.key, allClonePairs)
            .filter(clonePair => clonePair.clone_type === TYPE_1)
            .forEach(() => linkCls = "link--clone-type-1");

        // Create the diagram
        node
            .each(n => n.target = n.source = false);

        link
            .classed(linkCls, function(l) {

                // Since no mirrored
                if (l.source === d || l.target === d) {
                    l.source.source = true;
                    return l.source.source = true;
                }
            })
            .filter(function(l) { return l.target === d || l.source === d; })
            .each(function() { this.parentNode.appendChild(this); });

        node
            .classed("node--target", n => n.target)
            .classed("node--source", n => n.source);
    }

    GLClearHighlightFromDiagram = clearHighlightFromDiagram;
    GLSetupHighlightOnDiagram = setupHighlightOnDiagram;
    GNode = node;

    d3.select(self.frameElement).style("height", diameter + "px");
}