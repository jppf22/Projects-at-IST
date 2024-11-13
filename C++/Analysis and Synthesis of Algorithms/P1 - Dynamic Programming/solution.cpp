#include <iostream>
#include <array>
#include <vector>
#include <algorithm>
#include <map>

struct Piece
{
    int x;
    int y;
    int value;
};

int main()
{
    int dimensionX, dimensionY, numPieces;

    scanf("%d %d %d", &dimensionX,&dimensionY,&numPieces);

    std::vector<std::vector<int>> dp(dimensionX + 1, std::vector<int>(dimensionY + 1, 0));
    std::vector<std::vector<int>> values(dimensionX + 1, std::vector<int>(dimensionY + 1, 0));

    for (int i = 0; i < numPieces; i++) {
        Piece dummy{};
        scanf("%d %d %d", &dummy.x, &dummy.y, &dummy.value);

        if ((dummy.x <= dimensionX && dummy.y <= dimensionY) && (dummy.value > values[dummy.x][dummy.y])){
            values[dummy.x][dummy.y] = dummy.value;
        }

        if((dummy.y <= dimensionX && dummy.x <= dimensionY) && (dummy.value > values[dummy.y][dummy.x])){
            values[dummy.y][dummy.x] = dummy.value;
        }
    }

    for (int i = 0; i <= dimensionX; ++i){
        for (int j = 0; j <= dimensionY; ++j){ 
            if (i == 0 || j == 0) 
                dp[i][j] = 0;
            else {
                int maxValue = 0;

                if(values[i][j]){
                    maxValue = std::max(maxValue, values[i][j]);
                }

                for(int k=1 ; k <= i/2; k++){
                    maxValue = std::max(maxValue, dp[k][j] + dp[i - k][j]);
                }

                for (int k = 1; k <= j/2; ++k) {
                    maxValue = std::max(maxValue, dp[i][k] + dp[i][j - k]);
                }
                dp[i][j] = maxValue;
            }
        }
    }

    printf("%d\n", dp[dimensionX][dimensionY]);

    return 0;
}