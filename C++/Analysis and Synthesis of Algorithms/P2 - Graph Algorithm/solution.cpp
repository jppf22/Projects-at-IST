#include <iostream>
#include <algorithm>
#include <vector>
#include <stack>

void dfsAdj(int num, std::vector<bool>& used, std::vector<std::vector<int>>& adjMX, std::vector<int>& closestVertice) {
    std::stack<int> stack;
    stack.push(num);
    used[num] = true;

    while (!stack.empty()) {
        int current = stack.top();
        bool found = false;

        for (int x : adjMX[current]) {
            if (!used[x]) {
                stack.push(x);
                used[x] = true;
                found = true;
                break;
            }
        }

        if (!found) {
            closestVertice.push_back(current);
            stack.pop();
        }
    }
}

void dfsRevAdj(int start, std::vector<bool>& used, std::vector<std::vector<int>>& revadjMX, std::vector<int>& closestVertice, std::vector<int>& currentSCC) {
    std::stack<int> stack;
    stack.push(start);

    while (!stack.empty()) {
        int num = stack.top();
        stack.pop();

        if (!used[num]) {
            used[num] = true;
            currentSCC.push_back(num);

            for (int x : revadjMX[num]) {
                if (!used[x]) {
                    stack.push(x);
                }
            }
        }
    }
}

void longestPathCurrentNode(int num, std::vector<std::vector<int>>& adjSccMx, std::vector<bool>& used, std::vector<int>& longestPath, int& maxPath) {
    used[num] = true;
    for (int x : adjSccMx[num]) {
        if (!used[x]) {
            if (longestPath[x] == 0) {
                longestPathCurrentNode(x, adjSccMx, used, longestPath, maxPath);
            }
        }
        longestPath[num] = std::max(longestPath[num], 1 + longestPath[x]);
    }

    maxPath = std::max(maxPath, longestPath[num]);
}

int main() {

    int people, links;
    scanf("%d %d", &people, &links);

    std::vector<int> dummy{};
    std::vector<std::vector<int>> adjMX(people, dummy), revadjMX(people, dummy);
    std::vector<bool> used(people, false);
    std::vector<int> closestVertice;

    int u = 0, v = 0;
    for (int i = 0; i < links; i++) {
        scanf("%d %d", &u, &v);
        u -= 1;
        v -= 1;
        adjMX[u].push_back(v);
        revadjMX[v].push_back(u);
    }

    for (int i = 0; i < people; i++) {
        if (!used[i]) {
            dfsAdj(i, used, adjMX, closestVertice);
        }
    }

    std::reverse(closestVertice.begin(), closestVertice.end());
    used.assign(people, false);

    std::vector<int> previousNodes(people, 0);
    std::vector<int> sccRepresentative{};
    std::vector<std::vector<int>> adjSccMX(people, dummy);

    std::vector<int> currentScc{};
    for (auto x : closestVertice) {
        if (!used[x]) {
            dfsRevAdj(x, used, revadjMX, closestVertice, currentScc);
            int representative;
            if(!currentScc.empty()){
                representative = currentScc[0];
                for (auto oldNode : currentScc) previousNodes[oldNode] = representative;
            }
            else{
                representative = x;
            }
            sccRepresentative.push_back(representative);
            currentScc.clear();
        }
    }

    for (int i = 0; i < people; i++) {
        for (auto currentPersonConnection : adjMX[i]) {
            if (previousNodes[i] != previousNodes[currentPersonConnection]) {
                adjSccMX[previousNodes[i]].push_back(previousNodes[currentPersonConnection]);
            }
        }
    }

    int reducedPeople = adjSccMX.size();
    std::vector<bool> reducedUsed(reducedPeople, false);
    std::vector<int> longestPath(reducedPeople, 0); // Changed default path size to 0
    int maxPath = 0;
    for (int i = 0; i < reducedPeople; i++) {
        if (!reducedUsed[i]) {
            longestPathCurrentNode(i, adjSccMX, reducedUsed, longestPath, maxPath);
        }
    }
    
    printf("%d\n", maxPath);

    return 0;
}