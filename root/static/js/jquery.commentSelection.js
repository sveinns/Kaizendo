locations = {
    one     : {
        id              : 'one',
        url             : '/IHE/1/',
        start_path      : '/div/p:[1]',
        start_offset    : 31,
        end_path        : '/div/p:[1]',
        end_offset      : 68,
        child_paths     : [],
    },
    two     : {
        id              : 'two',
        url             : '/IHE/1/',
        start_path      : '/div/p:[1]',
        start_offset    : 62,
        end_path        : '/div/p:[1]',
        end_offset      : 119,
        child_paths     : [],
    },
    tre     : {
        id              : 'tre',
        url             : '/IHE/1/',
        start_path      : '/div/p[2]:[1]',
        start_offset    : 278,
        end_path        : '/div/p[2]:[1]',
        end_offset      : 292,
        child_paths     : [],
    },
};
comments = [
    {
        id          : 'one',
        location    : locations.one,
        in_reply_to : null,
        subject     : 'This is racist',
        content     : 'expand that thinking!'
    },
    {
        id          : 'two',
        location    : locations.two,
        in_reply_to : null,
        subject     : 'This is wrong',
        content     : 'What lessons?'
    },
    {
        id          : 'three',
        location    : locations.tre,
        in_reply_to : null,
        subject     : 'This is making an assumption',
        content     : 'Not me!'
    },
];
classes = {
    '^1$'           : 'single_comment',
    '^[2-4]$'       : 'few_comments',
    '^[5-9]$'       : 'some_comments',
    '^[1-2][0-9]$'  : 'many_comments',
    '^[3-4][0-9]$'  : 'excessive_comments',
    '^([5-9][0-9])|([0-9]{3,})$' : 'hot_topic'
};

$(document).ready(function(){
    $('#text_content').generateCommentClone();

    // bind Mouseup
    $('#text_content').bind("mouseup", function(){
        var range = $('#text_content').getRangeAt();
        // display comments
        var comments = getComments(range);
        displayComments(comments);
        // its a selection
        if (range.startContainer != range.endContainer || range.startOffset != range.endOffset) {
            $('div#comment_form').show().children('form').unbind('submit').submit(
                function() {
                    var location = createLocation(range);
                    var comment_data = {
                        subject     : this.subject.value,
                        content     : this.content.value,
                        location    : location
                    };
                    var comment = createComment(comment_data);
                    $('div#comment_form').hide();
                    this.reset();
                    $('#text_content').generateCommentClone();
                    return false;
                }
            );
        }
        else {
            $('div#comment_form').hide();
        }
    });
    // bind form submit (for comments)
    $('body').delegate('#comments form', 'submit',
        function(e) {
            alert('who whooo');
            e.preventDefault();
        }
    );
});

$.fn.getPath = function() {
    var xpath;
    if(this[0].nodeType == 3) {
        xpath = this.parent().getXPath()[0];
    }
    else {
        xpath = this.getXPath()[0];
    }
    var prepath = $('#text_content').getXPath();
    xpath = xpath.replace(prepath,'');
    return xpath+':['+this.nodeIndex()+']';
}

jQuery.fn.nodeIndex = function() {
    return $(this).prevAll().length + 1;
};

jQuery.fn.generateCommentClone = function() {
    var cloneHTML = $(this).generateCommentHTML();
    $(this).next('.clone').remove();
    $(this).after('<div class="clone">'+cloneHTML+'</div>');
};

$.fn.generateCommentHTML = function() {
    var newHTML = '';
    this.each(
        function() {
            var childNodes = this.childNodes;
            $(childNodes).each(
                function(index,element) {
                    if(this.nodeType == 3)
                    {
                        var range = $.fn.range;
                        range.startContainer = range.endContainer = element;
                        var path = $(element).getPath();
                        $.each(this.nodeValue,
                            function(index,cha) {
                                range.startOffset = range.endOffset = index+1;
                                var comments = getComments(range, path);
                                if(comments.length)
                                {
                                    var classes = getClasses(comments);
                                    newHTML += '<span class="'+classes+'">'+cha+'</span>';
                                }
                                else {
                                    newHTML += cha;
                                }
                            }
                        );
                    }
                    else {
                        //alert($(element).generateCommentHTML());
                        newHTML += '<'+this.tagName+'>'+$(this).generateCommentHTML()+'</'+this.tagName+'>';
                    }
                }
            );
        }
    );
    return newHTML;
}

function getClasses(comments) {
    var relevant_classes = [];
    $.each(comments,
        function(index,comment) {
            relevant_classes.push(comment.id);
        }
    );
    var count = comments.length+'';
    $.each(classes,
        function(exp,class) {
            var regex = new RegExp(exp);
            if(count.match(regex)) {
                relevant_classes.push(class);
            }
        }
    );
    return relevant_classes.join(' ');
}

// This should be extended to handle ranges with different start and ends
function getComments(range,path) {
    var foundComments = [];
    var start_path = path ? path : $(range.startContainer).getPath();
    var end_path = path ? path : $(range.endContainer).getPath();
    $.each(comments,
        function(index,comment) {
            var location = comment.location;
            // so(me [example text] here
            if(start_path == location.start_path) {
                // some [ex(...
                if(range.startOffset > location.start_offset) {
                    if(location.start_path == location.end_path) {
                        if(range.startOffset < location.end_offset) {
                            // some [ex(ample text] here
                            foundComments.push(comment);
                        }
                    }
                    else {
                        // some [ex(ample <b>text] here</b>
                        foundComments.push(comment);
                    }
                }
                // so(me [example text] here
                else if(location.start_path == location.end_path) {
                    if(end_path != location.end_path || range.endOffset > location.start_offset) {
                        // so(me [example text] <b>he)re</b> || // so(me [examp)le text] here
                        foundComments.push(comment);
                    }
                }
            }
            // <b>so(me</b> [example text] he)re
            // so(me <b>[example</b> text] he)re
            else if(end_path == location.end_path) {
                // <b>some</b> [example text] here
                if(location.start_path == location.end_path) {
                    if(range.endOffset > location.start_offset) {
                        // <b>so(me</b> [exam)ple text] here
                        foundComments.push(comment);
                    }
                }
                // some <b>[example</b> text] here
                else if(start_path == location.end_path) {
                    if(range.startOffset < location.end_offset) {
                        // some <b>[example</b> te(xt] here
                        foundComments.push(comment);
                    }
                }
            }
            // some [<b>e(xa)mple</b> text] here
            else if (location.child_paths.length) {
                $.each(location.child_paths,
                    function(index,path) {
                        if(start_path == path || end_path == path) {
                            // some [<b>e(xample</b> text] here || some [<b>exa)mple</b> text] here
                            foundComments.push(comment);
                            return;
                        }
                    }
                );
            }
            // <b>so(me</b> [example text] <b>he)re</b>
            else if(start_path != end_path) {
                var allNodes = range.GetContainedNodes()[0];
                if(allNodes.length > 2) {
                    allNodes.shift();
                    allNodes.pop();
                    $.each(allNodes,
                        function(index,node) {
                            var node_path = $(node).getPath();
                            if(node_path == location.start_path || node_path == location.end_path) {
                                foundComments.push(comment);
                                return;
                            }
                        }
                    );
                }
            }
        }
    );
    return foundComments;
}

// This should be extended to handle ranges with different start and ends
function displayComments(comments) {
    // Remove any previously selected text (blue)
    $('.selected').removeClass('selected');
    // remove any comments on the side
    $('#comments ol').children('li:first').siblings().remove();
    $.each(comments,
        function(index,comment) {
            var class = comment.id;
            $('.'+class).addClass('selected');
            var container = $('#comments ol').children('li:first').clone();
            container.children('p.comment_title').html(comment.subject);
            container.children('p.comment_content').html(comment.content);
            $('#comments ol').children('li:first').after(container);
        }
    );
}
function createLocation(range) {
    var nodes = [];
    var allNodes = range.GetContainedNodes()[0];
    if(allNodes.length > 2)
    {
        allNodes.shift();
        allNodes.pop();
        $.each(allNodes,
            function(index,node) {
                nodes.push($(node).getPath());
            }
        );
    }
    var location = {
        id              : new Date().getTime(),
        url             : '/IHE/1/',
        start_path      : $(range.startContainer).getPath(),
        start_offset    : range.startOffset,
        end_path        : $(range.endContainer).getPath(),
        end_offset      : range.endOffset+1,
        child_paths     : nodes,
    };
    locations[location.id] = location;
    return location;
}
function createComment(comment_data) {
    var comment = {
        id          : new Date().getTime(),
        location    : comment_data.location,
        subject     : comment_data.subject,
        content     : comment_data.content,
        in_reply_to : comment_data.parent
    };
    comments.push(comment);
}

// getLocation/getRange should be jquery functions
// $(#text_content).getLocation(range)
function getLocation(range) {
    var start_xpath = $(range.startContainer).parent().getXPath();
    var end_xpath = $(range.endContainer).parent().getXPath();
    // remember to make path relative to the container
    //start_xpath.replace('','');
    //end_xpath.replace('','');
    return start_xpath[0]+':'+range.startOffset+':'+end_xpath[0]+':'+range.endOffset;
}

// Needs to be based on the updated DOM?
// or get
function getRange(location) {
    var parts = location.split(':');
    var start_xpath = parts[0];
    var start_offset = parts[1];
    var end_xpath = parts[2];
    var end_offset = parts[3];
}

function highlightRange(range) {
}

// each time a span is added to the text, we need to increase the offset
// by the amount added (span with classes for highlighting)
function calculateOffset() {
    var difference = content.length - existing_length;
    offset += difference;
}

