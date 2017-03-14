function r = constwtcode(coding)
%CONSTWTCODE Given an input neural coding (e.g. the one generated by the
% getCoding() function, generates a new set of codes by taking the average
% weight of the codewords in C, rounding this to an integer w, and then
% generating constant-weight codes by randomly choosing w of the neurons to
% have an activation spike (i.e. equal 1).

    % Get properties
    len = coding.length; r.length = len;
    
    % Get average code word weight
    dirs = length(coding.dirs) + 1;
    mwt = round(sum(sum(repmat(coding.weights, [dirs, 1]) .* coding.wordprobs)));
    
    % Can't have more than size!/(size - mwt)!
    maxn = factorial(len) / factorial(len - mwt);
    if (maxn < coding.size)
        r.code = zeros(len, maxn);
        % Just generate all possible codes
        iAll = nchoosek(1:coding.size, mwt);
        for i = 1:maxn
            r.code(iAll(i,:), i) = 1;
        end
    else
        r.code = zeros(len, coding.size) - 2;  % +2 just for jitter
        for i = 1:coding.size
            p = randperm(len, mwt);
            w = zeros(len, 1);
            w(p) = 1;
            while (any(sum(w == r.code) == len))
                p = randperm(len, mwt);
                w = zeros(len, 1);
                w(p) = 1;
            end
            r.code(:, i) = w;
        end
    end
    
    % Get unique words
    r.words = unique(r.code', 'rows')';
    r.size = length(r.words);
    r.weights = sum(r.words);
    r.sparsity = sum(r.weights) / (r.size * len);
    r.redundancy = 1 - log2(r.size) / len;
end

