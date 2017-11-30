
N0 = 1e3; % initial number of isotopes scaled according to detector properties

% define grid of lambda and count values
n_lambdas = 20;
n_counts = 20;
std_time = zeros(n_lambdas, n_counts);
std_time_theor = zeros(n_lambdas, n_counts);
lambdas = linspace(0.00001, 0.0001, n_lambdas);
counts = linspace(0.1e2, 1e2, n_counts);
[X, Y] = meshgrid(lambdas, counts);

% calculate numerical and analytical standard deviations, in time, for each
% lambda and count 
for lambda_index = 1:n_lambdas
    for count_index = 1:n_counts
        std_time(lambda_index, count_index) = ...
            calculate_standard_deviation(N0, lambdas(lambda_index),... 
                                         counts(count_index))
        std_time_theor(lambda_index, count_index) = ...
            sqrt(counts(count_index)) / (lambdas(lambda_index) * N0)
    end
end

% print results
std_time
std_time_theor

% display surface plots of results
mesh(X, Y, std_time, 'EdgeColor','r')
hold on
mesh(X, Y, std_time_theor, 'EdgeColor', 'b')
xlabel('lambda')
ylabel('total counts')
zlabel('\sigma_{time}')

function [stdev] = calculate_standard_deviation(N0, lambda, counts_limit)
    % returns the standard deviation in times measured for counts_limit
    % counts.
    
	n_trials = 100; % number of trials to use in calculating statistical properties of t
	times = zeros(1, n_trials);
	for trial = 1:n_trials
		times(trial) = time_for_counts(N0, lambda, counts_limit);
    end
    
	stdev = std(times);
end

function [time] = time_for_counts(N0, lambda, counts_limit)
    % calculates the time taken to record counts_limit counts
    % for one trial using random decay events.
    
    tmax = 100000000000; % maximum time to allow
    tstep = 1; % width of time interval

    time = 0;
    decays_tot = 0;
    for t = tstep:tstep:tmax
        decays = 0;
        for particle = 1:N0 
            % probability that decay will not occur during this time step
            % given that the isotope exists at the start of the time interval			
            pr_not_dec = exp(-lambda * tstep);
            if rand > pr_not_dec
                decays = decays + 1;
            end
        end

        decays_tot = decays_tot + decays;
        N0 = N0 - decays;
        if decays_tot >= counts_limit
            time = t;
            return
        end
    end
    'time limit exceded'
end
