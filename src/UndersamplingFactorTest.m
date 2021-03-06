
min = 2;
max = 60;
Mmax = max;
Nmax = max;
max_spacing = 1;
Aperture_End = 64;
PerfectFact = zeros(3,max_spacing);
Subarrays = zeros(2,64);
Data = cell(2,1);
%I want to run the CoarrayTest for a range of undersampling factors
%They have to be coprime and so i'm using GenerateCoprimePairs to return a
%matrix of Pairs. Iterating through a small range of spacings, i will
%generate a matrix of pairs for each. Then I'll have to iterate through
%each coprime pair in each matrix and test it using CoarrayTest. This will return
%a Pairs matrix. If the max value of that matrix is zero it is discarded.
%Otherwise the U1 and U2 from Coprimes will be stored with the Pair data.

for spacing = 1:max_spacing
    Coprimes = GenerateCoprimePairs(min,max,spacing);
    
    for CoprNdx = 1:length(Coprimes)
        U1 = Coprimes{CoprNdx}(1); %The undersampling factors are set
        U2 = Coprimes{CoprNdx}(2);
        OptimalPairs = CoarrayTest(Mmax,Nmax,U1,U2,Aperture_End);
        F = find(OptimalPairs);
        if ~isempty(F)
            PerfectFact(:,spacing)= [spacing U1 U2]';
            disp(OptimalPairs); %displays a list of M and N pairings that 
                                %ensure a continuous coarray from the get
                                %go
        end
    end
end
%This script, working in concert with CoarrayTest, shows that in order to
%ensure a continuous coarray to use with directMUSIC and no missing lags,
%One of the undersampling factors and its associated subarray length must
%start at 2. Only odd spacings will produce a U1, U2 pair with perfect
%coprimes. So for example if M is 2 and the spacing is 5, then N must start
%at M+spacing=7. This is true for all M or N = 2. The other must start at a
%number equal to any odd spacing plus 2. M=2 N=7, M=2 N=9, and so on. Then
%with each of these base coprime pairs, there is a range of multiples that
%can be used to ensure a continuous coarray.5 

function [coprimes] = GenerateCoprimePairs(min,max,spacing)
% min is the lower bound in the range being searched. Max is the upper
% bound. Spacing sets the desired difference between the two coprimes. 

if spacing < 1
    spacing = 1;
end
if min < 2 % trivially don't want to test 1 since it's subarray is continuous
    min = 2;
    disp('Min too low, setting min to 2');
end
if min > max % Min must be greater than max
    error('Max must be greater than min');
end
%%
coprimes = cell(1, max); % Preallocate space 
for N = min+spacing:max % higher number n goes from min + spacing to max
    M = N-spacing; % lower number m
    factors_N = unique(factor(N)); % unique factors of N
        
    if ~ismember(M,factors_N) % if M is not a factor of N
        factors_M = unique(factor(M)); % find factors of M
    else
        factors_M = M; % else set M as the only factor of M
    end
    common_factors = intersect(factors_N, factors_M); % find intersection of factors of M and N
    if isempty(common_factors) % if there are no common factors
        coprimes{N} = [M,N]; % save pair as coprime
    end
end
coprimes = coprimes(~cellfun('isempty',coprimes)); % remove empty cell space
end