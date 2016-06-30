function line = returnLineFor(table, label)

txtMat = repmat({label}, size(table(:,1)));
i = cellfun(@strfind, table(:,1), txtMat, 'uniformoutput',false);
lineNo = find(~cellfun(@isempty,i));
line = table(lineNo,:);

end