function missing = GetMissingStats()

keys = {'evebitda','pb', 'pe','pfcf','ps'};
for key = keys
    data = evalin('base',key{:});
    missing.(key{:}) = getPercentageMissing(data);
end

end

function out = getPercentageMissing(data)
    i = data == 100000;
    out = length(find(i)) / length(i) * 100;
end
