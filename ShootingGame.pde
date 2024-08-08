Player player;
ArrayList<Enemy> enemies;
ArrayList<Bullet> bullets;
ArrayList<Bullet> enemyBullets;
ArrayList<Item> items;
int enemyCounter = 0;
int spawnInterval = 60; 
int spawnTimer = 0;
boolean bossSpawned = false;
BossEnemy boss;
boolean spacePressed = false; 
int lastShotTime = 0;

final int ENEMIES_REQUIRED_FOR_BOSS = 4;
UI ui;

abstract class Enemy {
  float x, y;
  float speed;
  int size;
  int hp;
  int shootInterval;
  int moveDirection = 1;
  color enemyColor; 

  Enemy(float x, float y, int hp, float speed, int shootInterval, color enemyColor) {
    this.x = x;
    this.y = y;
    this.hp = hp;
    this.speed = speed;
    this.size = 41;
    this.shootInterval = shootInterval;
    this.enemyColor = enemyColor; 
  }

  void update() {
    x += moveDirection * speed;
    if (x < size / 2 || x > width - size / 2) {
      moveDirection *= -1;
    }
  }

  void display() {
    if (enemyColor == color(255, 0, 255)) {
      rectMode(CENTER);
      fill(255, 255, 255);
      ellipse(x, y + size / 2, size, size);
      ellipse(x, y - size / 2, size * 2, size);
      fill(enemyColor);
      rect(x, y, size, size);
      fill(255, 255, 0);
      triangle(x - size / 2, y - size / 2, x - size / 2, y + size / 2, x - (size * 3) / 2, y - size / 2);
      triangle(x + size / 2, y - size / 2, x + size / 2, y + size / 2, x + (size * 3) / 2, y - size / 2);
    } else {
      rectMode(CENTER);
      fill(255);
      triangle(x + size / 2, y + size / 2, x - size / 2, y + size / 2, x, y + size);
      ellipse(x, y - size / 2, size / 3, size / 3);
      ellipse(x - size / 3, y - size / 2, size / 3, size / 3);
      ellipse(x + size / 3, y - size / 2, size / 3, size / 3);
      fill(enemyColor);
      rect(x, y, size, size);
    }
  }

  Bullet shoot() {
    return new Bullet(x, y + size / 2, 3, 5); 
  }

  boolean hits(Bullet b) {
    float d = dist(x, y, b.x, b.y);
    return d < size / 2 + b.size / 2;
  }
}

class BossEnemy extends Enemy {
  BossEnemy(float x, float y) {
    super(x, y, 70, 3, 60, color(255, 0, 255)); 
    this.size = 61;
  }

  void update() {
    super.update();
  }

  Bullet shoot(float playerX, float playerY) {
    float angle = atan2(playerY - y, playerX - x);
    float speedX = 3 * cos(angle);
    float speedY = 3 * sin(angle);
    return new Bullet(x, y + size / 2, speedX, speedY, 10); 
  }
}

class NormalEnemy extends Enemy {
  NormalEnemy(float x, float y) {
    super(x, y, 5, 1, 40, color(255, 0, 0)); 
  }
}

class SpeedEnemy extends Enemy {
  SpeedEnemy(float x, float y) {
    super(x, y, 5, 2, 40, color(0, 255, 0)); 
  }
}

class TankEnemy extends Enemy {
  TankEnemy(float x, float y) {
    super(x, y, 15, 1, 90, color(0, 0, 255)); 
  }
}

class SniperEnemy extends Enemy {
  SniperEnemy(float x, float y) {
    super(x, y, 5, 1, 20, color(255, 255, 0)); 
  }
}

class Player {
  float x, y;
  float speed;
  int size;
  int life;
  float dx, dy;
  boolean shieldActive;
  int shieldEndTime;
  int shotInterval;
  float bulletSpeed;
  int transparency;

  Player(float x, float y) {
    this.x = x;
    this.y = y;
    this.speed = 5;
    this.size = 31;
    this.life = 3;
    this.shieldActive = false;
    this.shotInterval = 500;
    this.bulletSpeed = -3;
  }

  void update() {
    x += dx * speed;
    y += dy * speed;
    x = constrain(x, size / 2, width - size / 2);
    y = constrain(y, height / 2, height - size / 2);
    if (shieldActive && millis() > shieldEndTime) {
      shieldActive = false;
    }
  }

  void display() {
    if (shieldActive) {
      transparency = 100;
    } else {
      transparency = 255;
    }
    rectMode(CENTER);
    fill(255, 255, 255, transparency);
    ellipse(x, y - size / 2, size, size);
    ellipse(x, y + size / 2, size * 2, size);
    fill(255, 200, 0, transparency);
    rect(x, y, size, size);
    fill(255, 255, 0, transparency);
    triangle(x - size / 2, y - size / 2, x - size / 2, y + size / 2, x - (size * 3) / 2, y + size / 2);
    triangle(x + size / 2, y - size / 2, x + size / 2, y + size / 2, x + (size * 3) / 2, y + size / 2);
  }

  void move(float dx, float dy) {
    this.dx = dx;
    this.dy = dy;
  }

  Bullet shoot() {
    return new Bullet(x, y - size / 2, bulletSpeed, 20);
  }

  boolean hits(Bullet b) {
    if (shieldActive) {
      return false;
    }
    float d = dist(x, y, b.x, b.y);
    return d < size / 2 + b.size / 2;
  }

  void activateShield(int duration) {
    shieldActive = true;
    shieldEndTime = millis() + duration;
  }
}

class Bullet {
  float x, y;
  float speedX, speedY;
  int size;

  Bullet(float x, float y, float speedY, int size) {
    this.x = x;
    this.y = y;
    this.speedX = 0;
    this.speedY = speedY;
    this.size = size;
  }

  Bullet(float x, float y, float speedX, float speedY, int size) {
    this.x = x;
    this.y = y;
    this.speedX = speedX;
    this.speedY = speedY;
    this.size = size;
  }

  void update() {
    x += speedX;
    y += speedY;
  }

  void display() {
    fill(255);
    ellipse(x, y, size, size);
    fill(255, 255, 0);
    rect(x, y + size / 2, size, size);
  }
}

class Item {
  float x, y;
  int size;
  int type; 

  Item(float x, float y, int type) {
    this.x = x;
    this.y = y;
    this.size = 15;
    this.type = type;
  }

  void display() {
    if (type == 0) {
      fill(0, 255, 0);
    } else if (type == 1) {
      fill(255, 255, 0);
    } else if (type == 2) {
      fill(0, 255, 255);
    } else if (type == 3) {
      fill(255, 0, 0);
    }
    rectMode(CENTER);
    rect(x, y, size, size);
  }

  boolean collected(Player player) {
    float d = dist(x, y, player.x, player.y);
    return d < size / 2 + player.size / 2;
  }

  void applyEffect(Player player) {
    if (type == 0) {
      player.life += 1;
    } else if (type == 1) {
      player.speed += 2;
    } else if (type == 2) {
      player.activateShield(5000);
    } else if (type == 3) {
      player.shotInterval -= 100;
      player.bulletSpeed -= 1; 
    }
  }
}



class UI {
  Player player;
  int enemyCounter;
  int enemiesRequiredForBoss;

  UI(Player player, int enemiesRequiredForBoss) {
    this.player = player;
    this.enemyCounter = 0;
    this.enemiesRequiredForBoss = enemiesRequiredForBoss;
  }

  void updateEnemyCounter() {
    this.enemyCounter++;
  }

  void display() {
    displayPlayerLife();
    displayEnemyCounter();
  }

  void displayPlayerLife() {
    fill(255, 0, 0);
    for (int i = 0; i < player.life; i++) {
      beginShape();
      vertex(10 + i * 27, 10);
      vertex(15 + i * 27, 15);
      vertex(20 + i * 27, 10);
      vertex(28 + i * 27, 18);
      vertex(15 + i * 27, 31);
      vertex(2 + i * 27, 18);
      vertex(10 + i * 27, 10);
      endShape();
    }
  }

  void displayEnemyCounter() {
    fill(0, 255, 0);
    textSize(25);
    textAlign(LEFT, TOP);
    text("撃破数: " + enemyCounter + " 体/ " + enemiesRequiredForBoss+"体", 10, 40);
    fill(255, 255, 0);
    text("撃破数: " + enemyCounter + " 体/ " + enemiesRequiredForBoss+"体", 11, 41);
    fill(255);
    text("撃破数: " + enemyCounter + " 体/ " + enemiesRequiredForBoss+"体", 12, 42);
  }
}

void setup() {
  size(800, 800);
  frameRate(60);
  player = new Player(width / 2, height - 50);
  enemies = new ArrayList<Enemy>();
  bullets = new ArrayList<Bullet>();
  enemyBullets = new ArrayList<Bullet>();
  items = new ArrayList<Item>();
  spawnEnemies();
  ui = new UI(player, ENEMIES_REQUIRED_FOR_BOSS);
  PFont font = createFont("Meiryo", 50);
  textFont(font);
}

void draw() {
  background(50, 0, 50);
  strokeWeight(1);
  for (int i = 0; i < 2; i++) {
    int colorNumber = int(random(3));
    int r = int(random(3, 7));
    if (colorNumber == 0 || colorNumber == 1) {
      fill(255);
    } else if (colorNumber == 2) {
      fill(255, 200, 0);
    } else {
      fill(255, 255, 0);
    }
    ellipse(int(random(width)), int(random(height)), r, r);
  }
  player.update();
  player.display();

  if (spacePressed && millis() - lastShotTime > player.shotInterval) {
    bullets.add(player.shoot());
    lastShotTime = millis();
  }

  for (int i = bullets.size() - 1; i >= 0; i--) {
    Bullet b = bullets.get(i);
    b.update();
    b.display();
    if (b.y < 0) {
      bullets.remove(i);
    }
  }

  for (int i = enemyBullets.size() - 1; i >= 0; i--) {
    Bullet eb = enemyBullets.get(i);
    eb.update();
    eb.display();
    if (eb.y > height) {
      enemyBullets.remove(i);
    } else if (player.hits(eb)) {
      player.life--;
      enemyBullets.remove(i);
      if (player.life <= 0) {
        fill(255, 0, 0);
        textSize(32);
        textAlign(CENTER, CENTER);
        text("GAME OVER", width / 2, height / 2);
        noLoop();
      }
    }
  }

  for (int i = enemies.size() - 1; i >= 0; i--) {
    Enemy e = enemies.get(i);
    e.update();
    e.display();
    if (spawnTimer % e.shootInterval == 0) {
      enemyBullets.add(e.shoot());
    }
    for (int j = bullets.size() - 1; j >= 0; j--) {
      Bullet b = bullets.get(j);
      if (e.hits(b)) {
        e.hp--;
        bullets.remove(j);
        if (e.hp <= 0) {
          enemies.remove(i);
          ui.updateEnemyCounter();
          float randomX = random(width);
          float yPos = height - 30;
          items.add(new Item(randomX, yPos, int(random(4))));
        }
      }
    }
  }

  if (bossSpawned) {
    boss.update();
    boss.display();
    if (spawnTimer % boss.shootInterval == 0) {
      enemyBullets.add(boss.shoot(player.x, player.y));
    }
    for (int j = bullets.size() - 1; j >= 0; j--) {
      Bullet b = bullets.get(j);
      if (boss.hits(b)) {
        boss.hp--;
        bullets.remove(j);
        if (boss.hp <= 0) {
          fill(255, 255, 0);
          textSize(32);
          textAlign(CENTER, CENTER);
          text("YOU WIN!", width / 2, height / 2);
          noLoop();
        }
        break;
      }
    }
  }

  for (int i = items.size() - 1; i >= 0; i--) {
    Item item = items.get(i);
    item.display();
    if (item.collected(player)) {
      item.applyEffect(player);
      items.remove(i);
    }
  }

  spawnTimer++;

  if (enemies.isEmpty() && !bossSpawned) {
    if (ui.enemyCounter < ENEMIES_REQUIRED_FOR_BOSS) { 
      spawnEnemies();
    } else {
      bossSpawned = true;
      boss = new BossEnemy(width / 2, height / 4);
    }
  }

  ui.display();
}

void keyPressed() {
  if (key == 'w') {
    player.move(0, -1);
  } else if (key == 's') {
    player.move(0, 1);
  } else if (key == 'a') {
    player.move(-1, 0);
  } else if (key == 'd') {
    player.move(1, 0);
  }
  if (key == ' ') {
    spacePressed = true; 
  }
}

void keyReleased() {
  if (key == 'w' || key == 's' || key == 'a' || key == 'd' ) {
    player.move(0, 0);
  }
  if (key == ' ') {
    spacePressed = false; 
  }
}

void spawnEnemies() {
  for (int i = 0; i < 4; i++) {
    int type = int(random(4));
    float x = random(width);
    float y = random(height / 2);

    if (type == 0) {
      enemies.add(new NormalEnemy(x, y));
    } else if (type == 1) {
      enemies.add(new SpeedEnemy(x, y));
    } else if (type == 2) {
      enemies.add(new TankEnemy(x, y));
    } else if (type == 3) {
      enemies.add(new SniperEnemy(x, y));
    }
  }
}
