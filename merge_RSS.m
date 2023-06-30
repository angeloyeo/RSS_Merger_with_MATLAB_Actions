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
    RSS_topics.(topics(i_topics)) = struct("xmlns_atomAttribute", "http://www.w3.org/2005/Atom", "versionAttribute", 2, "channel", struct('title',[],'description',[],'pubDate',[],'link',[]));
    while(1)
        if startsWith(myStr(p_topics_find(i_topics) + addNum),"*")
            feedURL = extractAfter(myStr(p_topics_find(i_topics) + addNum), "* ");
            tempXML = readstruct(feedURL, "FileType", "xml");

            RSS_topics.(topics(i_topics)).channel.title = [RSS_topics.(topics(i_topics)).channel.title; [tempXML.channel.item.title]'];
            limitedDescription = limitWidth(extractHTMLText([tempXML.channel.item.description]'), 100) + "...";
            RSS_topics.(topics(i_topics)).channel.description = [RSS_topics.(topics(i_topics)).channel.description; limitedDescription];

            pat = lettersPattern(3) + ", " + digitsPattern(2) + " " + lettersPattern(3) + " " + digitsPattern(4) + " " + digitsPattern(2) + ":" + digitsPattern(2) + ":" + digitsPattern(2);
            temp_pubDate = extract([tempXML.channel.item.pubDate]', pat);
            temp_pubDate = datetime(temp_pubDate, "InputFormat", "eee, dd MMM yyyy HH:mm:ss", "Locale", "en_US", "TimeZone", "+0000");
            RSS_topics.(topics(i_topics)).channel.pubDate = [RSS_topics.(topics(i_topics)).channel.pubDate; temp_pubDate];
            RSS_topics.(topics(i_topics)).channel.link = [RSS_topics.(topics(i_topics)).channel.link; [tempXML.channel.item.link]'];
            addNum = addNum + 1;
        else
            break;
        end

        if p_topics_find(i_topics) + addNum > length(myStr)
            break;
        end
    end
end

%% sort by date
for i_topics = 1:n_topics
    RSS_topics.(topics(i_topics)).channel = table2struct(sortrows(struct2table(RSS_topics.(topics(i_topics)).channel), "pubDate" ,"descend"));
end

%% change dateformat back to original
for i_topics = 1:n_topics
    for i_entity = 1:length(RSS_topics.(topics(i_topics)).channel)
        tempDate = RSS_topics.(topics(i_topics)).channel(i_entity).pubDate;
        RSS_topics.(topics(i_topics)).channel(i_entity).pubDate = ...
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