function shuffled = shuffledcode(coding)
%SHUFFLEDCODE Given an input neural coding (e.g. the one generated by the
% getCoding() function, generates a new set of codes by shuffling the
% neurons for each individual code such that no neuron is in its original
% location. The newly generated code should have the same length, size, and
% weight distribution.
    
    % Get properties
    len = coding.length; shuffled.length = len;
    shuffled.code = zeros(len, coding.tbins * length(coding.dirs) * coding.reps);
    
    % Get shuffled code
    s = 1;
    done = zeros(length(coding.words), 1);
    for t = 1:coding.tbins
        for d = 1:length(coding.dirs)
            for r = 1:coding.reps
                usable = 0;
                while (~usable)
                    p = randperm(len, len);
                    while (sum(p == (1:len)) > 0)
                        p = randperm(len, len);
                    end
                    a = ismember(coding.words', coding.code(p, t, d, r));
                    if ((sum(a) > 0) & (done(find(a, 1)) == 0))
                        done(find(a, 1)) = 1;
                        if (sum(done) == length(coding.words))
                            usable = 1;
                        end
                    end
                end
                shuffled.code(:, s) = coding.code(p, t, d, r);
                s = s + 1;
                done'
            end
        end
    end
    
    % Get unique words
    shuffled.words = unique(shuffled.code', 'rows')';
    shuffled.size = length(shuffled.words);
    shuffled.weights = sum(shuffled.words);
    shuffled.sparsity = sum(shuffled.weights) / (shuffled.size * len);
    shuffled.redundancy = 1 - log2(shuffled.size) / len;
end

