%此函数是用于帮助求解问题4的 函数代码逻辑与论文中图9决策树可以一一对应 请将此函数与q4.m放在同一文件夹下

function next_state = update_state(bo1, bo2, bo3, rest1, rest2, rest3)
    % 判断下一个系统状态是什么
    if bo2 == 0
        if rest2 == 0
            if bo1 > 0
                if bo3 > 0
                    next_state = [-1, 1, -1];
                elseif bo3 == 0
                    if rest3 > 0
                        next_state = [0, -1, 1];
                    elseif rest3 == 0
                        next_state = [-1, 1, 1];
                    end
                end    
            elseif bo1 == 0
                if rest1 == 0
                    if bo3 > 0
                        next_state = [1, 1, -1];
                    elseif bo3 == 0
                        if rest3 == 0
                            next_state = [1, 1, 1];
                        elseif rest3 > 0
                            next_state = [1, -1, 1];
                        end
                    end
                elseif rest1 > 0
                    if bo3 > 0
                        next_state = [1, -1, 0];
                    elseif bo3 == 0
                        next_state = [1, -1, 1];
                    end
                end
            end     
        elseif rest2 > 0
            if bo1 > 0
                if bo3 > 0
                    next_state = [-1, 1, -1];
                elseif bo3 == 0
                    if rest3 == 0
                        next_state = [-1, 1, -1];
                    elseif rest3 > 0
                        next_state = [-1, 1, 1];
                    end
                end
            elseif bo1 == 0
                if rest1 > 0
                    next_state = [1, 1, -1];
                elseif rest1 == 0
                    if bo3 > 0
                        next_state = [-1, 1, -1];
                    elseif bo3 == 0
                        if rest3 > 0
                            next_state = [-1, 1, 1];
                        elseif rest3 == 0
                            next_state = [-1, 1, -1];
                        end
                    end    
                end 
            end
        end
    elseif bo2 > 0
        if bo1 > 0
            if bo3 > 0
                next_state = [0, 0, 0];
            elseif bo3 == 0
                next_state = [0, -1, 1];
            end
        elseif  bo1 == 0
            if bo3 > 0
                next_state = [1, -1, 0];
            elseif bo3 == 0
                next_state = [1, -1, 1];
            end
        end
    end