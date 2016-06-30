morningstar = [];
l = length(tick);
i = 1;
for aTick = tick
    disp(sprintf('%d of %d', i, l));
    i = i + 1;
    morningstar = [morningstar getRatiosFromMorningStar(aTick{:}) ];
end