struct Card
    values::Array{Int64, 1}
    Card(value::Int64) = new([value]);
    Card(values::Array{Int64, 1}) = new(values);
end

# Binary and Unary operations have symbols and operations
abstract type Operation end;

# Binary and operations also have an inverse
struct Binary <: Operation
    operation::Function
    symbol::String
    inverse::Function
end

struct Unary <: Operation
    operation::Function
    symbol::String
end

Unaries = [Unary(identity, ""), Unary(sqrt, "sqrt")];
Binaries = [Binary(+, "+", -), Binary(-, "-", +), Binary(*, "*", /), Binary(/, "/", *)];

no_solution = "No Solution";

function try_funnel_pair(soln::String, cards::Array{Card, 1}, unaries::Array{Unary,1}, binaries::Array{Binary,1}, total::Float64)
    if length(cards) == 2
        for value1 in cards[1].values
            for value2 in cards[2].values
                for unary1 in unaries
                    currentValue1 = unary1.operation(value1);
                    stringValue1 = string(unary1.symbol, value1);
                    for unary2 in unaries
                        currentValue2 = unary2.operation(value2);
                        stringValue2 = string(unary2.symbol, value2);
                        for binary in binaries
                            if binary.operation(currentValue1, currentValue2) == total
                                return string("(", currentValue1, binary.symbol, currentValue2, ")");
                            end
                        end
                    end
                end
            end
        end
        return no_solution;
    else
        for i in length(cards)-1
            card1 = cards[i];
            for j in (i+1):length(cards)
                card2 = cards[j];
                for unary1 in unaries
                    for unary2 in unaries
                        for value1 in card1.values
                            for value2 in card2.values
                                currentValue1 = unary1.operation(value1);
                                currentValue2 = unary2.operation(value2);
                                stringValue1 = string(unary1.symbol, value1);
                                stringValue2 = string(unary2.symbol, value2);
                                for binary1 in binaries
                                    currentValue = binary1.operation(currentValue1, currentValue2);
                                    current_soln = string("(", stringValue1, binary1.symbol, stringValue2, ")");
                                    available_cards = deleteat!(deepcopy(cards), [min(i,j),max(i,j)]);
                                    for binary2 in binaries
                                        if binary2.inverse(total, currentValue) < Inf
                                            result = try_funnel_pair(current_soln, available_cards, unaries, binaries, binary2.inverse(total, currentValue));
                                            if result == no_solution
                                                continue;
                                            else
                                                return string(result, binary2.symbol, current_soln);
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    return no_solution;
end

# Recursive function that tries every permutation of unary and binary
# operations by looking at cards one at a time.
function funnel_helper(soln::String, cards::Array{Card, 1}, unaries::Array{Unary,1}, binaries::Array{Binary,1}, total::Float64)
    if length(cards) == 1
        for currentValue in cards[1].values
            for unary in unaries
                value = unary.operation(currentValue);
                if unary.operation(value) == total
                    stringValue = string(unary.symbol, value);
                    return string("((", stringValue);
                end
            end
        end
        return no_solution;
    else
        for unary in unaries
            for (i, card) in enumerate(cards)
                for value in card.values
                    currentValue = unary.operation(value);
                    stringValue = string(unary.symbol, value);
                    for binary in binaries
                        if length(cards) <= 2
                            current_soln = string(binary.symbol, stringValue);
                        else
                            current_soln = string(")", binary.symbol, stringValue);
                        end
                        available_cards = deleteat!(deepcopy(cards), i);
                        result = funnel_helper(current_soln, available_cards, unaries, binaries, binary.inverse(total, currentValue));
                        if result == no_solution
                            continue;
                        else
                            return string(result, current_soln);
                        end
                    end
                end
            end
        end
    end
    if isempty(soln)
        return try_funnel_pair(soln, cards, unaries, binaries, total);
    else
        return no_solution;
    end
end

# Finds a set of operations such that the four cards result in 24
function funnel(cards::Array{Card,1}, unaries::Array{Unary,1} = Unaries, binaries::Array{Binary,1} = Binaries)
    return @time funnel_helper("", cards, unaries, binaries, 24.0);
end

# Draws 4 random cards
function draw()
    cards = Card[];
    for i in 1:4
        val = rand(1:11);
        if val == 1 || val == 11
            card = Card([1,11]);
            push!(cards, card)
        else
            card = Card(val);
            push!(cards, card);
        end
    end
    return cards;
end
