PImage title, gameover, startNormal, startHovered, restartNormal, restartHovered;
PImage groundhogIdle, groundhogLeft, groundhogRight, groundhogDown;
PImage bg, life, cabbage, stone1, stone2, soilEmpty;
PImage soldier;
PImage soil0, soil1, soil2, soil3, soil4, soil5;
PImage[][] soils, stones;

final int GAME_START = 0, GAME_RUN = 1, GAME_OVER = 2;
int gameState = 0;

final int GRASS_HEIGHT = 15;
final int SOIL_COL_COUNT = 8;
final int SOIL_ROW_COUNT = 24;
final int SOIL_SIZE = 80;

int[][] soilHealth;

final int START_BUTTON_WIDTH = 144;
final int START_BUTTON_HEIGHT = 60;
final int START_BUTTON_X = 248;
final int START_BUTTON_Y = 360;

float[] cabbageX, cabbageY, soldierX, soldierY;
float soldierSpeed = 2f;

float playerX, playerY;
int playerCol, playerRow;
final float PLAYER_INIT_X = 4 * SOIL_SIZE;
final float PLAYER_INIT_Y = - SOIL_SIZE;
boolean leftState = false;
boolean rightState = false;
boolean downState = false;
int playerHealth = 2;
final int PLAYER_MAX_HEALTH = 5;
int playerMoveDirection = 0;
int playerMoveTimer = 0;
int playerMoveDuration = 15;
int[][] empty;
boolean demoMode = false;
boolean autoDown=false;
void setup() {
  size(640, 480, P2D);
  bg = loadImage("img/bg.jpg");
  title = loadImage("img/title.jpg");
  gameover = loadImage("img/gameover.jpg");
  startNormal = loadImage("img/startNormal.png");
  startHovered = loadImage("img/startHovered.png");
  restartNormal = loadImage("img/restartNormal.png");
  restartHovered = loadImage("img/restartHovered.png");
  groundhogIdle = loadImage("img/groundhogIdle.png");
  groundhogLeft = loadImage("img/groundhogLeft.png");
  groundhogRight = loadImage("img/groundhogRight.png");
  groundhogDown = loadImage("img/groundhogDown.png");
  life = loadImage("img/life.png");
  soldier = loadImage("img/soldier.png");
  cabbage = loadImage("img/cabbage.png");
  soilEmpty = loadImage("img/soils/soilEmpty.png");

  // Load soil images used in assign3 if you don't plan to finish requirement #6
  soil0 = loadImage("img/soil0.png");
  soil1 = loadImage("img/soil1.png");
  soil2 = loadImage("img/soil2.png");
  soil3 = loadImage("img/soil3.png");
  soil4 = loadImage("img/soil4.png");
  soil5 = loadImage("img/soil5.png");

  // Load PImage[][] soils
  soils = new PImage[6][5];
  for(int i = 0; i < soils.length; i++){
    for(int j = 0; j < soils[i].length; j++){
      soils[i][j] = loadImage("img/soils/soil" + i + "/soil" + i + "_" + j + ".png");
      }
    }

  // Load PImage[][] stones
  stones = new PImage[2][5];
  for(int i = 0; i < stones.length; i++){
    for(int j = 0; j < stones[i].length; j++){
      stones[i][j] = loadImage("img/stones/stone" + i + "/stone" + i + "_" + j + ".png");
    }
  }

  // Initialize player
  playerReset();
  playerHealth = 2;

  // Initialize soilHealth
  soilHealth = new int[SOIL_COL_COUNT][SOIL_ROW_COUNT]; // [8][24]
  soilHealthReset();
        
  // Initialize soidiers and their position
  soldierX = new float[6];
  soldierY = new float[6];
  soidierReset();

  // Initialize cabbages and their position
  cabbageX = new float[6];  
  cabbageY = new float[6];  
  cabbageReset();
  
  
  //fill ONE or TWO value into empty array
  empty = new int[23][2];
  int rnd = 0; 
  for(int i=0; i<empty.length; i++){  
  rnd = floor(random(1,3)); // set the condition is ONE/TWO
    if(rnd ==1){
      empty[i][0] = floor(random(0,8)); // set where the empty location is
      empty[i][1] = -1; // it stands for : there is no need to fill value.
    }
    if(rnd ==2){
      empty[i][0] = floor(random(0,8)); // set where the empty location is
      empty[i][1] = floor(random(0,8)); // set where the empty location is
      while(empty[i][0]==empty[i][1]){
        empty[i][1] = floor(random(0,8)); // when these two values are the same, then reset again : make sure that [0]!=[1]
      }
    }
  } 
}

void draw() {

	switch (gameState) {

		case GAME_START: // Start Screen
		image(title, 0, 0);
		if(START_BUTTON_X + START_BUTTON_WIDTH > mouseX
	    && START_BUTTON_X < mouseX
	    && START_BUTTON_Y + START_BUTTON_HEIGHT > mouseY
	    && START_BUTTON_Y < mouseY) {
			image(startHovered, START_BUTTON_X, START_BUTTON_Y);
			if(mousePressed){
				gameState = GAME_RUN;
				mousePressed = false;
			}
		}else{
			image(startNormal, START_BUTTON_X, START_BUTTON_Y);
		}
		break;

		case GAME_RUN: // In-Game
		// Background
		image(bg, 0, 0);

		// Sun
    stroke(255,255,0);
	  strokeWeight(5);
	  fill(253,184,19);
	  ellipse(590,50,120,120);

	  // CAREFUL!
	  // Because of how this translate value is calculated, the Y value of the ground level is actually 0
		pushMatrix();
		translate(0, max(SOIL_SIZE * -18, SOIL_SIZE * 1 - playerY));

		// Ground
		fill(124, 204, 25);
		noStroke();
		rect(0, -GRASS_HEIGHT, width, GRASS_HEIGHT);

		// Soil
		for(int i = 0; i < soilHealth.length; i++){
			for(int j = 0; j < soilHealth[i].length; j++){
          int areaIndex = floor(j / 4);
          if(soilHealth[i][j]>12){
            image(soils[areaIndex][4], i * SOIL_SIZE, j * SOIL_SIZE);
          }else if(soilHealth[i][j]>9){
            image(soils[areaIndex][4], i * SOIL_SIZE, j * SOIL_SIZE);
          }
          else if(soilHealth[i][j]>6){
            image(soils[areaIndex][3], i * SOIL_SIZE, j * SOIL_SIZE);
          }
          else if(soilHealth[i][j]>3){
            image(soils[areaIndex][2], i * SOIL_SIZE, j * SOIL_SIZE);
          }else if(soilHealth[i][j]>0){
            image(soils[areaIndex][0], i * SOIL_SIZE, j * SOIL_SIZE);
          }else{
            image(soilEmpty, i * SOIL_SIZE, j * SOIL_SIZE);
          } 
				// Change this part to show soil and stone images based on soilHealth value
				// NOTE: To avoid errors on webpage, you can either use floor(j / 4) or (int)(j / 4) to make sure it's an integer.
      }
    }
    
    // Stones
    showStones();
  
  // put the empty image above all images
  for(int i=0; i<23; i++){ // from 2nd~24th : total is 23
    //empty[i][0] is a row number, and i means in the colum i
    //cause which row had one or two empty, [0]means first empty is in where
    image(soilEmpty, empty[i][0]*SOIL_SIZE, (i+1)*SOIL_SIZE); // (i+1) is because there is no empty in the first layer 
    soilHealth[ empty[i][0] ][i+1] = 0;
    if(empty[i][1] != -1){ //-1 means there isn't a value in this position of array
      image(soilEmpty, empty[i][1]*SOIL_SIZE, (i+1)*SOIL_SIZE);
      soilHealth[ empty[i][1] ][i+1] = 0;
    }
  }

		// cabbages
    if(playerHealth < PLAYER_MAX_HEALTH){
      for(int i=0; i<cabbageX.length; i++){
        image(cabbage, cabbageX[i], cabbageY[i]);
        // eat cabbages detection
        if(cabbageX[i]+SOIL_SIZE>playerX && cabbageX[i]<playerX+SOIL_SIZE){
          if(cabbageY[i]+SOIL_SIZE>playerY && cabbageY[i]<playerY+SOIL_SIZE){
            cabbageX[i] = 800;
            playerHealth++;
          }
        }
      }
    }else{
       for(int i=0; i<cabbageX.length; i++){
         image(cabbage, cabbageX[i], cabbageY[i]);
       }
    }
    
    // auto down
    if(playerRow+1<24 && soilHealth[playerCol][playerRow+1]==0){
      downState=true;
      rightState=false;
      leftState=false;
    }else if(playerRow==23){
      downState=false;
    }

		// Groundhog
		PImage groundhogDisplay = groundhogIdle;
		if(playerMoveTimer == 0){
			if(leftState){
				groundhogDisplay = groundhogLeft;

				// Check left boundary
				if(playerCol > 0){
          if(playerRow>=0){            
            if(soilHealth[playerCol-1][playerRow]>0){
              soilHealth[playerCol-1][playerRow]-=1;  
              playerX=playerCol*SOIL_SIZE;
              playerMoveTimer = 0;
            }
            if(soilHealth[playerCol-1][playerRow]==0){              
              playerMoveTimer = playerMoveDuration;
            }
          }else{
            playerMoveTimer = playerMoveDuration;
          }
					playerMoveDirection = LEFT;
				}
			}else if(rightState){
				groundhogDisplay = groundhogRight;

				// Check right boundary
				if(playerCol < SOIL_COL_COUNT - 1){
          if(playerRow>=0){
            if(soilHealth[playerCol+1][playerRow]>0){
             soilHealth[playerCol+1][playerRow]-=1;
             playerX=playerCol*SOIL_SIZE;
             playerMoveTimer = 0;
            }
            if(soilHealth[playerCol+1][playerRow]==0){              
             playerMoveTimer = playerMoveDuration;
            }
          }else{
            playerMoveTimer = playerMoveDuration;
          }
					playerMoveDirection = RIGHT;
				}

			}else if(downState){
				groundhogDisplay = groundhogDown;

        // Check bottom boundary
				if(playerRow < SOIL_ROW_COUNT - 1){
            if(soilHealth[playerCol][playerRow+1]>0){
              if(!autoDown){
                downState=false;
              }else{
                soilHealth[playerCol][playerRow+1] -= 1; // the speed of decreasing soilHealth
                playerY = playerRow*SOIL_SIZE;
                playerMoveTimer = 0;
              } 
            }
            if(soilHealth[playerCol][playerRow+1]==0){
              playerMoveTimer = playerMoveDuration;
              downState=false;
            }
					playerMoveDirection = DOWN;
				}
			}
		}

		// If player is now moving?
		// (Separated if-else so player can actually move as soon as an action starts)
		// (I don't think you have to change any of these)

		if(playerMoveTimer > 0){
			playerMoveTimer --;
			switch(playerMoveDirection){

				case LEFT:
				groundhogDisplay = groundhogLeft;
				if(playerMoveTimer == 0){       
          playerCol--;
          playerX = SOIL_SIZE * playerCol;
				}else{
					playerX = (float(playerMoveTimer) / playerMoveDuration + playerCol - 1) * SOIL_SIZE;
				}
				break;

				case RIGHT:
				groundhogDisplay = groundhogRight;
				if(playerMoveTimer == 0){
					playerCol++;        
					playerX = SOIL_SIZE * playerCol;
				}else{
					playerX = (1f - float(playerMoveTimer) / playerMoveDuration + playerCol) * SOIL_SIZE;
				}
				break;

				case DOWN:
				groundhogDisplay = groundhogDown;
				if(playerMoveTimer == 0){
					playerRow++;
 					playerY = SOIL_SIZE * playerRow;
				}else{
					playerY = (1f - float(playerMoveTimer) / playerMoveDuration + playerRow) * SOIL_SIZE;
				}
				break;
			}

		}
		image(groundhogDisplay, playerX, playerY);

		//soldiers
    for(int i=0; i<soldierX.length; i++){
      //hit soldiers detection
      if(soldierX[i]>playerX && soldierX[i]-SOIL_SIZE<playerX+SOIL_SIZE){
        if(soldierY[i]+SOIL_SIZE>playerY && soldierY[i]<playerY+SOIL_SIZE){
           for(int k=0; k<8; k++){
             if(soilHealth[k][0]==0){
               soilHealth[k][0]=15;
             }
           }
           playerReset();
           playerHealth--;
        }
      }
      soldierX[i] %= width+SOIL_SIZE;
      image(soldier,soldierX[i]-80,soldierY[i]);   
      soldierX[i] += soldierSpeed;
    }

		// > Remember to stop player's moving! (reset playerMoveTimer)
		// > Remember to recalculate playerCol/playerRow when you reset playerX/playerY!
		// > Remember to reset the soil under player's original position!

		// Demo mode: Show the value of soilHealth on each soil
		// (DO NOT CHANGE THE CODE HERE!)

		if(demoMode){	

			fill(255);
			textSize(26);
			textAlign(LEFT, TOP);

			for(int i = 0; i < soilHealth.length; i++){
				for(int j = 0; j < soilHealth[i].length; j++){
					text(soilHealth[i][j], i * SOIL_SIZE, j * SOIL_SIZE);
				}
			}
		}

		popMatrix();

		// Health UI
    for(int i=0; i<playerHealth; i++){
      image(life, 10+(50+20)*i, 10);
    }
    if(playerHealth ==0){
      gameState = GAME_OVER;
    }
		break;

		case GAME_OVER: // Gameover Screen
		image(gameover, 0, 0);
		
		if(START_BUTTON_X + START_BUTTON_WIDTH > mouseX
	    && START_BUTTON_X < mouseX
	    && START_BUTTON_Y + START_BUTTON_HEIGHT > mouseY
	    && START_BUTTON_Y < mouseY) {

			image(restartHovered, START_BUTTON_X, START_BUTTON_Y);
			if(mousePressed){
				gameState = GAME_RUN;
				mousePressed = false;

				// Initialize player
				playerReset();
				playerHealth = 2;

				// Initialize soilHealth
				soilHealthReset();

				// Initialize soidiers and their position
        soidierReset();       
          
       	// Initialize cabbages and their position
        cabbageReset();
        
     	}        
   	}else{
     		image(restartNormal, START_BUTTON_X, START_BUTTON_Y);        
  	}
		break;
	}
}

void keyPressed(){
	if(key==CODED){
		switch(keyCode){
			case LEFT:
			leftState = true;
			break;
			case RIGHT:
			rightState = true;
			break;
			case DOWN:
      autoDown=true;
			downState = true;
			break;
		}
	}else{
		if(key=='b'){
			// Press B to toggle demo mode
			demoMode = !demoMode;
		}
	}
}

void keyReleased(){
	if(key==CODED){
		switch(keyCode){
			case LEFT:
			leftState = false;
			break;
			case RIGHT:
			rightState = false;
			break;
			case DOWN:
      autoDown=false;
      downState = false;
			break;
		}
	}
}

void playerReset(){
  playerX = PLAYER_INIT_X;
  playerY = PLAYER_INIT_Y;
  playerCol = (int) (playerX / SOIL_SIZE);
  playerRow = (int) (playerY / SOIL_SIZE);
  playerMoveTimer = 0;
}

void soilHealthReset(){
  for(int i = 0; i < soilHealth.length; i++){
    for (int j = 0; j < soilHealth[i].length; j++) {
       // 0: no soil, 15: soil only, 30: 1 stone, 45: 2 stones
      soilHealth[i][j] = 15;
    }
  }
   // soilHealth 0~8
  for(int i=0; i<8; i++){
    for(int j=0; j<8; j++){
      if(i == j){
        soilHealth[i][j] = 30;
      }
    }
  }
   // soilHealth 9~16
      for(int i=0; i<8; i++){
        for(int j=8; j<16; j++){
          if(i%4==0 || i%4==3){
            if(j%4==1 || j%4==2){
              soilHealth[i][j] = 30;
            }
          }
          if(i%4==1 || i%4==2){
            if(j%4==0 || j%4==3){
              soilHealth[i][j] = 30;
            }
          }
        }
      }
      // soilHealth 17~24
      for(int i=0; i<8; i++){
        for(int j=16; j<24; j++){
          //stone0
            if(i%3==1 || i%3==2){
              if(j%3==1){
                soilHealth[i][j] = 30;
              }
            }
          if(i%3==0 || i%3==1){
            if(j%3==2){
              soilHealth[i][j] = 30;
            }  
          }
          if(i%3==0 || i%3==2){
            if(j%3==0){
              soilHealth[i][j] = 30; 
            }
          }
          // stone1
          if(i%3==2 && j%3==1){
            soilHealth[i][j] = 45; 
          }
          if(i%3==1 && j%3==2){
            soilHealth[i][j] = 45; 
          }
          if(i%3==0 && j%3==0){
            soilHealth[i][j] = 45; 
          } 
        }
      }
}

void soidierReset(){
  for(int i=0; i<soldierX.length; i++){
    soldierX[i] = floor(random(0, width));
  }
  for(int i=0; i<soldierY.length; i++){
      float area = (SOIL_ROW_COUNT/6)*i;
      float area2 = (SOIL_ROW_COUNT/6)*(i+1);
      soldierY[i] = floor(random(area,area2))*SOIL_SIZE;    
  }
}

void cabbageReset(){
  for(int i=0; i<8; i++){
    for(int j=0; j<cabbageX.length; j++){
      cabbageX[j] = floor(random(0, i))*SOIL_SIZE;
    }
  }
  for(int i=0; i<cabbageX.length; i++){
      float area = (SOIL_ROW_COUNT/6)*i;
      float area2 = (SOIL_ROW_COUNT/6)*(i+1);
      cabbageY[i] = floor(random(area,area2))*SOIL_SIZE;    
  }
}

void showStones(){
  PImage x = soilEmpty;
  PImage x2 = soilEmpty;
  // stone 1~8
  for(int i=0; i<8; i++){
    for(int j=0; j<8; j++){
      if(soilHealth[i][j]>27){
        x=stones[0][4];
      }else if(soilHealth[i][j]>24){
        x=stones[0][3];
      }else if(soilHealth[i][j]>21){
        x=stones[0][2];
      }else if(soilHealth[i][j]>18){
        x=stones[0][1];
      }else if(soilHealth[i][j]>15){
        x=stones[0][0];
      }
      if(i == j){
        if(soilHealth[i][j]>15){
          image(x, SOIL_SIZE*i, SOIL_SIZE*j);    
        }
      }
    }
  }
  // stone 9~16
  for(int i=0; i<8; i++){
    for(int j=8; j<16; j++){
      if(soilHealth[i][j]>27){
        x=stones[0][4];
      }else if(soilHealth[i][j]>24){
        x=stones[0][3];
      }else if(soilHealth[i][j]>21){
        x=stones[0][2];
      }else if(soilHealth[i][j]>18){
        x=stones[0][1];
      }else if(soilHealth[i][j]>15){
        x=stones[0][0];
      }
      if(soilHealth[i][j]>15){
        if(i%4==0 || i%4==3){
          if(j%4==1 || j%4==2){
            image(x, SOIL_SIZE*i, SOIL_SIZE*j);
            }
        }
        if(i%4==1 || i%4==2){
          if(j%4==0 || j%4==3){
              image(x, SOIL_SIZE*i, SOIL_SIZE*j);
          }
        }
      }
    } 
  }
  // stone 17~24
  for(int i=0; i<8; i++){
    for(int j=16; j<24; j++){
      //stone0 17~24
      if(soilHealth[i][j]>27){
        x=stones[0][4];
      }else if(soilHealth[i][j]>24){
        x=stones[0][3];
      }else if(soilHealth[i][j]>21){
        x=stones[0][2];
      }else if(soilHealth[i][j]>18){
        x=stones[0][1];
      }else if(soilHealth[i][j]>15){
        x=stones[0][0];
      }
      if(soilHealth[i][j]>15){
        if(i%3==1 || i%3==2){
          if(j%3==1){
            image(x, SOIL_SIZE*i, SOIL_SIZE*j);
          }
        }
        if(i%3==0 || i%3==1){
          if(j%3==2){
            image(x, SOIL_SIZE*i, SOIL_SIZE*j);
          }  
        }
        if(i%3==0 || i%3==2){
          if(j%3==0){
            image(x, SOIL_SIZE*i, SOIL_SIZE*j);  
          }
        }
      }
      //stone1 17~24
      if(soilHealth[i][j]>42){
        x2=stones[1][4];
      }else if(soilHealth[i][j]>39){
        x2=stones[1][3];
      }else if(soilHealth[i][j]>36){
        x2=stones[1][2];
      }else if(soilHealth[i][j]>33){
        x2=stones[1][1];
      }else if(soilHealth[i][j]>30){
        x2=stones[1][0];
      }  
      if(soilHealth[i][j]>30){
       if(i%3==2 && j%3==1){
         image(x2, SOIL_SIZE*i, SOIL_SIZE*j); 
          }
        if(i%3==1 && j%3==2){
          image(x2, SOIL_SIZE*i, SOIL_SIZE*j);
        }
        if(i%3==0 && j%3==0){
          image(x2, SOIL_SIZE*i, SOIL_SIZE*j);
        } 
      }
    }
  }
}
