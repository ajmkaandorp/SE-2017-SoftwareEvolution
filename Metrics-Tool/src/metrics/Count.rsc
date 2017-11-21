module metrics::Count
// Copy pasted from Joana for testing purposes (So do not hand this in!)

import IO;
import List;

public int countTotalLines(list[str] file){
    return size(file);
}

public int countTotalLinesProject(list[loc] project){
    lines = 0;
    for(p <- project)
        lines += countTotalLines(readFileLines(p));
    return lines;
}

public int countBlankLines(list[str] file){
    count = 0;
    for(l <- file){
        if(/^[ \t\n]*$/ := l) count += 1;
    }
    return count;
}

public int countBlankLinesProject(list[loc] project){
    lines = 0;
    for(p <- project)
        lines += countBlankLines(readFileLines(p));
    return lines;
}

public int countCommentLines(list[str] file){
    count = 0;
    open = 0;

    for(l <- file){
            if(/^[\s\t\n]*\/\// := l){
                count += 1;
            }

            else if(/^.*\*\/[\s\t\n]*$/ := l){
                if(!(!/^[\s\t\n]*\/\*.*\*\/$/ := l && /^[\s\t\n]*<x:[\s\S]+>\/\*.*\*\/$/ := l)){
                    count += 1;
                    open = 0;
                }   
            }
            
            else if(open == 1 && !(/^[ \t\n]*$/ := l)){
                count += 1;
            }
         
            else if(/^[\s\t\n]*\/\*.*$/ := l){
                count += 1;
                open = 1;
            }

            else if(/^[\s\t\n\S]*\/\*.*/ := l){
                    if(!/^[\s\t\n\S]*\"[\s\S]*\/\*|^.*\*\// := l) open = 1;
            }       
    }
    return count;
}

public int countCommentLinesProject(list[loc] project){
    lines = 0;
    for(p <- project)
        lines += countCommentLines(readFileLines(p));
    return lines;

}

public int countCodeLines (list[str] file){
    return (size(file) - countBlankLines(file) - countCommentLines(file) );
}

public list[int] countCodeLinesProject(list[loc] project){
    lines = [];
    for(p <- project)
        lines += [countCodeLines(readFileLines(p))];
    return lines;
}

