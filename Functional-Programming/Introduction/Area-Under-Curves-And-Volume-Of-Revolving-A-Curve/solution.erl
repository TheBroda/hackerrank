-module(solution).
-export([main/0]).

% Take a line of strings space separated and transform it
% into a List of strings (removing the line break)
lineAsListOfStrings(Line) ->
    re:split(string:strip(Line -- "\n"), " ", [{return,list}]).

% Read the input as a string (line of numbers, space separated)
% and return {ok, ListOfIntegers}
readLineAsList() ->
    case io:get_line("") of
        eof ->
            ok;
        N ->
            {ok, [ list_to_integer(X) || X <- lineAsListOfStrings(N) ]}
    end.

% We are going to build a recursive function to act like the polynomial
% After we use all coefficients and exponents, the break condition for the
% recursion is to return an anonymous function that always returns zero
buildEquation([], []) -> fun(_) -> 0 end;

% Function buildEquation will return a function that behaves exactly as the
% polynomial under evaluation.
% This way we'll build the equation only once for both integrations
buildEquation([Coef|Coefficients], [Exp|Exponents]) ->
    % The second term of the following sum will expand into a similar
    % anonymous function, using the next coefficient and exponent and
    % immediately calling it with X
    fun(X) -> Coef*math:pow(X, Exp) + (buildEquation(Coefficients, Exponents))(X) end.

% Proxy call to integrate, to initialize two Accumulators (Area and Volume)
% and to fix the initial point of both integrations
integrate(Equation, [Begin, End], DeltaX) ->
    integrate(Equation, End, DeltaX, Begin, {0, 0}).

% Break condition for the recursion
% (the current point is greater than the End limit)
integrate(_, End, _, X, Accumulator) when X > End -> Accumulator;

% Calculate both integrals in parallel. For each point of the interval
% calculate the area under the curve (evaluation of the polynomial at X
% times the length of the increment (DeltaX))
% AND
% calculate the volume generated by revolving this area around the X-axis.
% Each partial volume is a cylinder with height equals to length of the
% increment (DeltaX) and the transversal area is a circle with radius
% equals to the evaluation of the polynomial at X
integrate(Equation, End, DeltaX, X, {AreaAccumulator, VolumeAccumulator}) ->
    % This way we evaluate the polynomial at X only once for each increment
    Evaluation = Equation(X),
    Area = DeltaX*Evaluation,
    Volume = DeltaX*math:pow(Evaluation, 2)*math:pi(),
    integrate(Equation, End, DeltaX, X+DeltaX, {AreaAccumulator+Area, VolumeAccumulator+Volume}).

main() ->
    % Get the coefficients
    {ok, Coefficients} = readLineAsList(),
    % Get the exponents
    {ok, Exponents} = readLineAsList(),
    % Get the integration limits
    {ok, Limits} = readLineAsList(),
    % Build the polynomial function
    Equation = buildEquation(Coefficients, Exponents),
    % Calculate and output both integration results
    {Area, Volume} = integrate(Equation, Limits, 0.001),
    io:format("~.1f~n~.1f~n", [Area, Volume]).
