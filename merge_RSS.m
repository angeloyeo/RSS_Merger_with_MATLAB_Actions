%% entry template
template = struct;
template.id = "";
template.published = "";
template.updated = "";
template.link = struct;
template.link.relAttribute = 'alternate';
template.link.relAttribute = convertCharsToStrings( ...
  template.link.relAttribute);
template.link.typeAttribute = 'text/html';
template.link.typeAttribute = convertCharsToStrings( ...
  template.link.typeAttribute);
template.link.hrefAttribute = "";
template.title = "";
template.content = "";
template.author = struct;
template.author.name = "";
template.author.uri = "";
template.category = struct;
template.category(1).termAttribute = "";
template.category(2).termAttribute = "";

%%
myStr = readlines("README.md");
myStr(strcmp(myStr,"")) = [];
startsWith(myStr, "*")

% RSS topics
n_topics = sum(startsWith(myStr, "##"));
p_topics = startsWith(myStr, "##"); % p stands for position
topics = extractAfter(myStr(p_topics), "## ");
topics = replace(topics," ", "_");
RSS_topics = {};
for i_topics = 1:n_topics
    p_topics_find = find(p_topics);
    addNum = 1;

    buildDate = string(day(datetime("now"), 'shortname')) + ", " + ...
        datestr(datetime("now"), "dd mmm yyyy HH:MM:ss") + ...
        " +0000";

    linkStruct = struct('relAttribute', "alternate", 'typeAttribute', "text/html", 'hrefAttribute', []);
    authorStruct = struct('name', [], 'uri', []);
    categoryStruct = struct;
    categoryStruct.termAttribute = ["cat1"; "cat2"];

    entryStruct = struct('id', [], 'published', [], 'updated', [], 'link', linkStruct,...
        'title',[], 'content', [], 'author', authorStruct, 'category', categoryStruct);

    RSS_topics.(topics(i_topics)) = struct(...
        'xmlInsAttribute', "http://www.w3.org/2005/Atom",...
        'xml_langAttribute', "en-US",...
        'title', topics(i_topics),...
        'updated', buildDate,...
        'entry', entryStruct);

    while(1)
        if startsWith(myStr(p_topics_find(i_topics) + addNum),"*")
            feedURL = extractAfter(myStr(p_topics_find(i_topics) + addNum), "* ");
            tempXML = readstruct(feedURL, "FileType", "xml");

            for i_item = 1:length([tempXML.channel.item.title])


                limitedDescription = limitWidth(extractHTMLText(tempXML.channel.item(i_item).description), 100) + "...";

                pat = lettersPattern(3) + ", " + digitsPattern(2) + " " + lettersPattern(3) + " " + digitsPattern(4) + " " + digitsPattern(2) + ":" + digitsPattern(2) + ":" + digitsPattern(2);
                temp_pubDate = extract(tempXML.channel.item(i_item).pubDate', pat);
                temp_pubDate = datetime(temp_pubDate, "InputFormat", "eee, dd MMM yyyy HH:mm:ss", "Locale", "en_US", "TimeZone", "+0000");
                
                template.id = " ";
                template.published = datetime(temp_pubDate, 'format', "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'");
                template.updated = template.published;
                template.link.hrefAttribute = tempXML.channel.item(i_item).link;
                template.title = tempXML.channel.item(i_item).title;
                template.content= limitedDescription;
                template.author.name = " ";
                template.author.uri = " ";
                RSS_topics.(topics(i_topics)).entry = [template, RSS_topics.(topics(i_topics)).entry];
            end

            addNum = addNum + 1;
        else
            break;
        end

        if p_topics_find(i_topics) + addNum > length(myStr)
            break;
        end
    end
    RSS_topics.(topics(i_topics)).entry(end) = []; % removing template
end

%% sort by date
for i_topics = 1:n_topics
    RSS_topics.(topics(i_topics)).entry = ...
        table2struct(...
            sortrows(struct2table(RSS_topics.(topics(i_topics)).entry), "published" ,"descend"));
end

%% change dateformat back to original
for i_topics = 1:n_topics
    for i_entity = 1:length([RSS_topics.(topics(i_topics)).entry.published])
        tempDate = RSS_topics.(topics(i_topics)).entry(i_entity).published;
        RSS_topics.(topics(i_topics)).entry(i_entity).published = string(tempDate);
        RSS_topics.(topics(i_topics)).entry(i_entity).updated = string(tempDate);
    end
end

%% save to XML
for i_topics = 1:n_topics
    writestruct(RSS_topics.(topics(i_topics)), topics(i_topics)+".xml","structNodeName","feed")
end

function s = limitWidth(s, n)
s = extractBefore(s, min(n, s.strlength()) + 1);
end