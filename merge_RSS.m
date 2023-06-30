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
    itemStruct = struct('title',[],'link',[],'pubDate',[],'description',[]);
    channelStruct = struct('generator', "NFE/5.0", 'title', topics(i_topics),'link', "https://raw.githubusercontent.com/angeloyeo/RSS_Merger_with_MATLAB_Actions/main/"+topics(i_topics)+".xml", ...
        'language', "ko", 'webMaster', "angeloyeo@gmail.com", 'copyright', "Angelo Yeo", ...
        'lastBuildDate', buildDate, 'description', topics(i_topics), 'item', itemStruct);
    RSS_topics.(topics(i_topics)) = struct("xmlns_atomAttribute", "http://www.w3.org/2005/Atom", "versionAttribute", 2, ...
        "channel", channelStruct);

    while(1)
        if startsWith(myStr(p_topics_find(i_topics) + addNum),"*")
            feedURL = extractAfter(myStr(p_topics_find(i_topics) + addNum), "* ");
            tempXML = readstruct(feedURL, "FileType", "xml");

            for i_item = 1:length([tempXML.channel.item.title])
                RSS_topics.(topics(i_topics)).channel.item(end+1).title = tempXML.channel.item(i_item).title;
                limitedDescription = limitWidth(extractHTMLText(tempXML.channel.item(i_item).description), 100) + "...";
                RSS_topics.(topics(i_topics)).channel.item(end).description = limitedDescription;

                pat = lettersPattern(3) + ", " + digitsPattern(2) + " " + lettersPattern(3) + " " + digitsPattern(4) + " " + digitsPattern(2) + ":" + digitsPattern(2) + ":" + digitsPattern(2);
                temp_pubDate = extract(tempXML.channel.item(i_item).pubDate', pat);
                temp_pubDate = datetime(temp_pubDate, "InputFormat", "eee, dd MMM yyyy HH:mm:ss", "Locale", "en_US", "TimeZone", "+0000");
                RSS_topics.(topics(i_topics)).channel.item(end).pubDate = temp_pubDate;
                RSS_topics.(topics(i_topics)).channel.item(end).link = tempXML.channel.item(i_item).link;
            end

            addNum = addNum + 1;
        else
            break;
        end

        if p_topics_find(i_topics) + addNum > length(myStr)
            break;
        end
    end
    RSS_topics.(topics(i_topics)).channel.item(1) = []
end

%% sort by date
for i_topics = 1:n_topics
    RSS_topics.(topics(i_topics)).channel.item = table2struct(sortrows(struct2table(RSS_topics.(topics(i_topics)).channel.item), "pubDate" ,"descend"));
end

%% change dateformat back to original
for i_topics = 1:n_topics
    for i_entity = 1:length(RSS_topics.(topics(i_topics)).channel)
        tempDate = RSS_topics.(topics(i_topics)).channel.item(i_entity).pubDate;
        RSS_topics.(topics(i_topics)).channel.item(i_entity).pubDate = ...
            string(day(tempDate, 'shortname'))' + ", " + ...
            datestr(tempDate, "dd mmm yyyy HH:MM:ss") + ...
            " +0000";
    end
end

%% save to XML
for i_topics = 1:n_topics
    writestruct(RSS_topics.(topics(i_topics)), topics(i_topics)+".xml","structNodeName","feed")
end

function s = limitWidth(s, n)
s = extractBefore(s, min(n, s.strlength()) + 1);
end