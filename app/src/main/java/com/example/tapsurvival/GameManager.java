package com.example.tapsurvival;

import com.example.tapsurvival.Icon;

import android.content.Context;
import android.content.SharedPreferences;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.LinearGradient;
import android.graphics.Paint;
import android.graphics.Path;
import android.graphics.RadialGradient;
import android.graphics.RectF;
import android.graphics.Shader;
import android.media.AudioAttributes;
import android.media.SoundPool;
import android.media.MediaPlayer;
import android.os.Vibrator;
import android.util.Log;



import java.util.ArrayList;
import java.util.List;
import java.util.Random;

public class GameManager {
    private List<Icon> allIcons;
    private List<ThemeColor> allSkins;
    private MediaPlayer mediaPlayer;
    private List<ThemeColor> allThemes;
    private int bullets;
    private float buttonHeight;
    private float buttonSpacing;
    private float buttonWidth;
    private String[] cachedSubLines;
    private Icon currentIcon;
    private int currentLevel;
    private ThemeColor currentObstacleColor;
    private Icon currentObstacleShape;
    private ThemeColor currentSkin;
    private ThemeColor currentTheme;
    private int gems;
    private boolean hasSavedGame;
    private int highScore;
    private float itemCardHeight;
    private float itemCardWidth;
    private float itemSpacing;
    private long lastItemSpawnTime;
    private long lastSpawnTime;
    private int levelTargetScore;
    private List<ThemeColor> obstacleColors;
    private List<Icon> obstacleShapes;
    private List<ThemeColor> playerColors;
    private SharedPreferences prefs;
    private int screenHeight;
    private int screenWidth;
    private int soundCollect;
    private int soundCrash;
    private boolean soundEnabled;
    private boolean musicEnabled;
    private int soundFever;
    private int soundGhost;
    private int soundLevelUp;
    private int soundMagnet;
    private SoundPool soundPool;
    private int soundShield;
    private int soundShoot;
    private int soundSwitch;
    private long startTime;
    private int superBullets;
    private String unlockedIconsStr;
    private String unlockedObstacleShapesStr;
    private String unlockedPlayerThemesStr;
    private String unlockedSkinsStr;
    private String unlockedThemesStr;
    private boolean vibrationEnabled;
    private Vibrator vibrator;
    private static final int COLOR_PRIMARY = Color.parseColor("#D0BCFF");
    private static final int COLOR_ON_PRIMARY = Color.parseColor("#381E72");
    private static final int COLOR_PRIMARY_CONTAINER = Color.parseColor("#4F378B");
    private static final int COLOR_SURFACE = Color.parseColor("#1C1B1F");
    private static final int COLOR_SURFACE_VARIANT = Color.parseColor("#49454F");
    private static final int COLOR_ON_SURFACE = Color.parseColor("#E6E1E5");
    private static final int COLOR_SECONDARY = Color.parseColor("#CCC2DC");
    private static final int COLOR_TERTIARY = Color.parseColor("#EFB8C8");
    private static final int COLOR_OUTLINE = Color.parseColor("#938F99");
    private volatile State currentState = State.MAIN_MENU;
    private volatile State previousState = State.MAIN_MENU;
    private long spawnInterval = 1500;
    private float obstacleSpeed = 15.0f;
    private int shakeDuration = 0;
    private Random random = new Random();
    private int score = 0;
    private int bonusScore = 0;
    private int combo = 0;
    private float comboMultiplier = 1.0f;
    private float lastObstacleX = -1.0f;
    private long lastObstacleSpawnTime = 0;
    private int speedUpIndicator = 0;
    private float lastSpeed = 15.0f;
    private int magnetTimer = 0;
    private int ghostTimer = 0;
    private int feverTimer = 0;
    private int sameLaneCount = 0;
    private int starCombo = 0;
    private int shopTab = 0;
    private int settingsTab = 0;
    private float shopScrollY = 0.0f;
    private float settingsScrollY = 0.0f;
    private float lastTouchY = 0.0f;
    private int perfectDodgeIndicator = 0;
    private long pauseStartTime = 0;
    private int lastLevelTargetScore = 0;
    private long lastPlayerTouchTime = 0;
    private int countdown = 0;
    private int levelUpIndicator = 0;
    private float transitionAlpha = 1.0f;
    private State nextState = null;
    private boolean isTransitioning = false;
    private long savedElapsedTime = 0;
    private boolean isInitialCountdown = false;
    private String lastSubText = "";
    private RectF tempRect = new RectF();
    private RectF headerRect = new RectF();
    private RectF badgeRect = new RectF();
    private RectF buttonRect = new RectF();
    private Path tempPath = new Path();
    private boolean soundLoaded = false;
    private List<FloatingText> floatingTexts = new ArrayList();
    private List<Obstacle> obstacles = new ArrayList();
    private List<Collectible> collectibles = new ArrayList();
    private List<Particle> particles = new ArrayList();

    public enum State {
        MAIN_MENU,
        PLAYING,
        PAUSED,
        GAME_OVER,
        SHOP,
        SETTINGS,
        ABOUT,
        HIGH_SCORES
    }

    private class FloatingText {
        String text;
        float x;
        float y;
        int alpha = 255;
        float vy = -2.0f;

        FloatingText(float x, float y, String text) {
            this.x = x;
            this.y = y;
            this.text = text;
        }
    }

    public GameManager(Context context, int screenWidth, int screenHeight) {
        this.highScore = 0;
        this.gems = 0;
        this.unlockedIconsStr = "default";
        this.unlockedThemesStr = "red_sq";
        this.unlockedPlayerThemesStr = "default";
        this.unlockedObstacleShapesStr = "square";
        this.levelTargetScore = 5000;
        this.currentLevel = 1;
        this.bullets = 0;
        this.superBullets = 0;
        this.hasSavedGame = false;
        this.unlockedSkinsStr = "default";
        this.vibrationEnabled = true;
        this.soundEnabled = true;
        this.musicEnabled = true;
        this.screenWidth = screenWidth;
        this.screenHeight = screenHeight;
        this.prefs = context.getSharedPreferences("GamePrefs", 0);
        this.highScore = this.prefs.getInt("highScore", 0);
        this.gems = this.prefs.getInt("gems", 0);
        this.bullets = this.prefs.getInt("bullets", 0);
        this.superBullets = this.prefs.getInt("superBullets", 0);
        this.currentLevel = this.prefs.getInt("currentLevel", 1);
        this.levelTargetScore = this.prefs.getInt("levelTargetScore", 5000);
        this.hasSavedGame = this.prefs.getBoolean("hasSavedGame", false);
        this.unlockedIconsStr = this.prefs.getString("unlockedIcons", "default,circle,triangle");
        this.unlockedThemesStr = this.prefs.getString("unlockedThemes", "red_sq");
        this.unlockedPlayerThemesStr = this.prefs.getString("unlockedPlayerThemes", "default");
        this.unlockedObstacleShapesStr = this.prefs.getString("unlockedObstacleShapes", "square");
        this.vibrationEnabled = this.prefs.getBoolean("vibrationEnabled", true);
        this.soundEnabled = this.prefs.getBoolean("soundEnabled", true);
        this.musicEnabled = this.prefs.getBoolean("musicEnabled", true);
        AudioAttributes attrs = new AudioAttributes.Builder().setUsage(14).setContentType(4).build();
        this.soundPool = new SoundPool.Builder().setMaxStreams(5).setAudioAttributes(attrs).build();
        this.soundSwitch = this.soundPool.load(context, R.raw.switch_lane, 1);
        this.soundCollect = this.soundPool.load(context, R.raw.collect, 1);
        this.soundFever = this.soundPool.load(context, R.raw.fever, 1);
        this.soundLevelUp = this.soundPool.load(context, R.raw.level_up, 1);
        this.soundMagnet = this.soundPool.load(context, R.raw.magnet, 1);
        this.soundShield = this.soundPool.load(context, R.raw.shield, 1);
        this.soundGhost = this.soundPool.load(context, R.raw.ghost, 1);
        this.soundCrash = this.soundPool.load(context, R.raw.crash, 1);
        this.soundPool.setOnLoadCompleteListener(new SoundPool.OnLoadCompleteListener() {
            @Override
            public void onLoadComplete(SoundPool soundPool, int sampleId, int status) {
                soundLoaded = true;
            }
        });
        this.vibrator = (Vibrator) context.getSystemService("vibrator");
        initCustomization();
        try {
            this.mediaPlayer = MediaPlayer.create(context, R.raw.bgm);
            if (this.mediaPlayer != null) {
                this.mediaPlayer.setLooping(true);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        updateMusicState();
        this.unlockedSkinsStr = this.prefs.getString("unlockedSkins", "default");
        this.buttonWidth = screenWidth * 0.75f;
        this.buttonHeight = screenHeight * 0.08f;
        this.itemCardWidth = screenWidth * 0.85f;
        this.itemCardHeight = screenHeight * 0.12f;
        this.itemSpacing = this.itemCardHeight * 1.2f;
        this.buttonSpacing = this.buttonHeight * 1.35f;
    }


    private void initCustomization() {
        this.allIcons = new ArrayList();
        this.allIcons.add(new Icon("default", "Square", Icon.Type.SQUARE, "", 0, true));
        this.allIcons.add(new Icon("circle", "Circle", Icon.Type.CIRCLE, "", 0, true));
        this.allIcons.add(new Icon("triangle", "Triangle", Icon.Type.TRIANGLE, "", 0, true));
        int level = getCurrentLevel();
        this.allIcons.add(new Icon("girl", "Girl", Icon.Type.EMOJI, "👧", 0, level >= 2));
        this.allIcons.add(new Icon("boy", "Boy", Icon.Type.EMOJI, "👦", 0, level >= 3));
        this.allIcons.add(new Icon("rocket", "Rocket", Icon.Type.EMOJI, "🚀", 0, level >= 4));
        this.allIcons.add(new Icon("alien", "Alien", Icon.Type.EMOJI, "👾", 0, level >= 5));
        this.allIcons.add(new Icon("robot", "Robot", Icon.Type.EMOJI, "🤖", 0, level >= 6));
        this.allIcons.add(new Icon("car", "Car", Icon.Type.EMOJI, "🚗", 0, level >= 7));
        this.allIcons.add(new Icon("gem", "Gem", Icon.Type.EMOJI, "💎", 0, level >= 8));
        this.allIcons.add(new Icon("crown", "Crown", Icon.Type.EMOJI, "👑", 0, level >= 9));
        this.allIcons.add(new Icon("cat", "Cat", Icon.Type.EMOJI, "🐱", 0, level >= 10));
        this.allIcons.add(new Icon("dog", "Dog", Icon.Type.EMOJI, "🐶", 0, level >= 11));
        this.allIcons.add(new Icon("sun", "Sun", Icon.Type.EMOJI, "☀️", 0, level >= 12));
        this.allIcons.add(new Icon("lion", "Lion", Icon.Type.EMOJI, "🦁", 0, level >= 13));
        this.allIcons.add(new Icon("tiger", "Tiger", Icon.Type.EMOJI, "🐯", 0, level >= 14));
        this.allIcons.add(new Icon("panda", "Panda", Icon.Type.EMOJI, "🐼", 0, level >= 15));
        this.allIcons.add(new Icon("koala", "Koala", Icon.Type.EMOJI, "🐨", 0, level >= 16));
        this.allIcons.add(new Icon("frog", "Frog", Icon.Type.EMOJI, "🐸", 0, level >= 17));
        this.allIcons.add(new Icon("octopus", "Octopus", Icon.Type.EMOJI, "🐙", 0, level >= 18));
        this.playerColors = new ArrayList();
        this.playerColors.add(new ThemeColor("default", "Cyan", Color.parseColor("#00E5FF"), 0, true));
        this.playerColors.add(new ThemeColor("ruby", "Ruby", Color.RED, 50, this.unlockedPlayerThemesStr.contains("ruby")));
        this.playerColors.add(new ThemeColor("gold", "Gold", Color.parseColor("#FFD600"), 75, this.unlockedPlayerThemesStr.contains("gold")));
        this.playerColors.add(new ThemeColor("purple", "Purple", Color.parseColor("#AA00FF"), 60, this.unlockedPlayerThemesStr.contains("purple")));
        this.playerColors.add(new ThemeColor("white", "White", -1, 100, this.unlockedPlayerThemesStr.contains("white")));
        this.playerColors.add(new ThemeColor("neon_green", "Neon", Color.parseColor("#39FF14"), 80, this.unlockedPlayerThemesStr.contains("neon_green")));
        this.obstacleShapes = new ArrayList();
        this.obstacleShapes.add(new Icon("square", "Square", Icon.Type.SQUARE, "", 0, true));
        this.obstacleShapes.add(new Icon("circle", "Circle", Icon.Type.CIRCLE, "", 0, true));
        this.obstacleShapes.add(new Icon("triangle", "Triangle", Icon.Type.TRIANGLE, "", 0, true));
        this.obstacleShapes.add(new Icon("hex", "Hexagon", Icon.Type.HEXAGON, "", 50, this.unlockedObstacleShapesStr.contains("hex")));
        this.obstacleShapes.add(new Icon("diamond", "Diamond", Icon.Type.DIAMOND, "", 60, this.unlockedObstacleShapesStr.contains("diamond")));
        this.obstacleShapes.add(new Icon("heart", "Heart", Icon.Type.HEART, "", 70, this.unlockedObstacleShapesStr.contains("heart")));
        this.obstacleShapes.add(new Icon("pentagon", "Pentagon", Icon.Type.PENTAGON, "", 80, this.unlockedObstacleShapesStr.contains("pentagon")));
        this.obstacleColors = new ArrayList();
        this.obstacleColors.add(new ThemeColor("danger_red", "Danger Red", Color.parseColor("#FF1744"), 0, true));
        this.obstacleColors.add(new ThemeColor("frost_blue", "Frost Blue", Color.parseColor("#1E88E5"), 40, this.unlockedThemesStr.contains("frost_blue")));
        this.obstacleColors.add(new ThemeColor("acid_green", "Acid Green", Color.parseColor("#43A047"), 40, this.unlockedThemesStr.contains("acid_green")));
        this.obstacleColors.add(new ThemeColor("void_purple", "Void Purple", Color.parseColor("#AA00FF"), 60, this.unlockedThemesStr.contains("void_purple")));
        this.obstacleColors.add(new ThemeColor("sunset", "Sunset", Color.parseColor("#FF5722"), 50, this.unlockedThemesStr.contains("sunset")));
        this.allSkins = new ArrayList();
        this.allSkins.add(new ThemeColor("default", "Classic Space", Color.parseColor("#1C1B1F"), 0, true));
        this.allSkins.add(new ThemeColor("neon", "Neon City", Color.parseColor("#000000"), 100, this.unlockedSkinsStr.contains("neon")));
        this.allSkins.add(new ThemeColor("sunset_skin", "Deep Sunset", Color.parseColor("#210002"), 150, this.unlockedSkinsStr.contains("sunset_skin")));
        this.allSkins.add(new ThemeColor("matrix", "Digital Rain", Color.parseColor("#001000"), 200, this.unlockedSkinsStr.contains("matrix")));
        String iconId = this.prefs.getString("currentIconId", "default");
        for (Icon i : this.allIcons) {
            if (i.id.equals(iconId) && i.unlocked) {
                this.currentIcon = i;
            }
        }
        if (this.currentIcon == null) {
            this.currentIcon = this.allIcons.get(0);
        }
        String pColorId = this.prefs.getString("currentPlayerColorId", "default");
        for (ThemeColor t : this.playerColors) {
            if (t.id.equals(pColorId)) {
                this.currentTheme = t;
            }
        }
        if (this.currentTheme == null) {
            this.currentTheme = this.playerColors.get(0);
        }
        String oShapeId = this.prefs.getString("currentObstacleShapeId", "square");
        for (Icon i2 : this.obstacleShapes) {
            if (i2.id.equals(oShapeId)) {
                this.currentObstacleShape = i2;
            }
        }
        if (this.currentObstacleShape == null) {
            this.currentObstacleShape = this.obstacleShapes.get(0);
        }
        String oColorId = this.prefs.getString("currentObstacleColorId", "danger_red");
        for (ThemeColor t2 : this.obstacleColors) {
            if (t2.id.equals(oColorId)) {
                this.currentObstacleColor = t2;
            }
        }
        if (this.currentObstacleColor == null) {
            this.currentObstacleColor = this.obstacleColors.get(0);
        }
        String skinId = this.prefs.getString("currentSkinId", "default");
        for (ThemeColor t3 : this.allSkins) {
            if (t3.id.equals(skinId)) {
                this.currentSkin = t3;
            }
        }
        if (this.currentSkin == null) {
            this.currentSkin = this.allSkins.get(0);
        }
        updateObstacleTheme();
    }

    private void updateObstacleTheme() {
        if (this.currentObstacleColor != null && this.currentObstacleShape != null) {
            Obstacle.setGlobalTheme(this.currentObstacleColor, this.currentObstacleShape.type);
        }
    }

    public void update(Player player) {
        int i;
        char c;
        int i2;
        Collectible.Type type;
        float f;
        boolean z = this.isTransitioning;
        float f2 = this.transitionAlpha;
        float f3 = 0.15f;
        if (z) {
            this.transitionAlpha = f2 - 0.15f;
            if (this.transitionAlpha <= 0.0f) {
                this.currentState = this.nextState;
                this.isTransitioning = false;
                this.transitionAlpha = 0.0f;
                return;
            }
            return;
        }
        if (f2 < 1.0f) {
            this.transitionAlpha += 0.15f;
            if (this.transitionAlpha > 1.0f) {
                this.transitionAlpha = 1.0f;
            }
        }
        for (int i3 = this.floatingTexts.size() - 1; i3 >= 0; i3--) {
            FloatingText ft = this.floatingTexts.get(i3);
            ft.y -= 4.0f;
            ft.alpha -= 8;
            if (ft.alpha <= 0) {
                this.floatingTexts.remove(i3);
            }
        }
        if (this.currentState != State.PLAYING) {
            updateVisuals();
            if (this.shakeDuration > 0) {
                this.shakeDuration--;
                return;
            }
            return;
        }
        if (this.countdown > 0) {
            this.countdown--;
            if (this.isInitialCountdown) {
                updateVisuals();
                return;
            }
        }
        long elapsed = System.currentTimeMillis() - this.startTime;
        this.score = ((int) ((elapsed / 500) * this.comboMultiplier)) + this.bonusScore;
        this.obstacleSpeed = (elapsed / 12000.0f) + 15.0f;
        if (this.obstacleSpeed > this.lastSpeed + 1.0f) {
            this.speedUpIndicator = 60;
            this.lastSpeed = this.obstacleSpeed;
        }
        this.spawnInterval = Math.max(600L, 1500 - ((elapsed / 10000) * 100));
        if (this.score >= this.levelTargetScore) {
            levelUp();
        }
        if (System.currentTimeMillis() - this.lastSpawnTime <= this.spawnInterval) {
            f3 = 0.15f;
        } else {
            if (this.feverTimer > 0) {
                this.collectibles.add(new Collectible(this.screenWidth, this.obstacleSpeed, Collectible.Type.STAR));
                f3 = 0.15f;
            } else {
                Obstacle newObstacle = new Obstacle(this.screenWidth, this.obstacleSpeed);
                if (newObstacle.x == this.lastObstacleX) {
                    this.sameLaneCount++;
                } else {
                    this.sameLaneCount = 0;
                }
                boolean laneSwitched = newObstacle.x != this.lastObstacleX;
                float timeSinceLast = System.currentTimeMillis() - this.lastObstacleSpawnTime;
                if (laneSwitched && timeSinceLast < 600.0f) {
                    newObstacle.x = this.lastObstacleX;
                    this.sameLaneCount++;
                } else if (!laneSwitched && this.sameLaneCount >= 3) {
                    float f4 = newObstacle.x;
                    float f5 = (this.screenWidth / 4.0f) - (newObstacle.size / 2.0f);
                    int i4 = this.screenWidth;
                    if (f4 == f5) {
                        f = ((i4 * 3) / 4.0f) - (newObstacle.size / 2.0f);
                    } else {
                        f = (i4 / 4.0f) - (newObstacle.size / 2.0f);
                    }
                    newObstacle.x = f;
                    this.sameLaneCount = 0;
                }
                this.obstacles.add(newObstacle);
                this.lastObstacleX = newObstacle.x;
                this.lastObstacleSpawnTime = System.currentTimeMillis();
            }
            this.lastSpawnTime = System.currentTimeMillis();
        }
        char c2 = 2;
        if (System.currentTimeMillis() - this.lastItemSpawnTime > this.random.nextInt(4000) + 4000) {
            float r = this.random.nextFloat();
            if (r < 0.25f) {
                type = Collectible.Type.STAR;
            } else if (r < 0.35f) {
                type = Collectible.Type.SHIELD;
            } else if (r < 0.45f) {
                type = Collectible.Type.MAGNET;
            } else {
                type = r < 0.55f ? Collectible.Type.GHOST : Collectible.Type.GEM;
            }
            this.collectibles.add(new Collectible(this.screenWidth, this.obstacleSpeed, type));
            if (type == Collectible.Type.GEM && this.random.nextFloat() < f3) {
                for (int j = 1; j <= 2; j++) {
                    Collectible extraGem = new Collectible(this.screenWidth, this.obstacleSpeed, Collectible.Type.GEM);
                    extraGem.y = (-extraGem.size) * (j + 1) * 2;
                    this.collectibles.add(extraGem);
                }
            }
            this.lastItemSpawnTime = System.currentTimeMillis();
        }
        int i5 = this.collectibles.size() - 1;
        while (i5 >= 0) {
            Collectible c3 = this.collectibles.get(i5);
            c3.update();
            if (this.magnetTimer <= 0) {
                i = i5;
                c = c2;
            } else if (c3.type == Collectible.Type.STAR || c3.type == Collectible.Type.GEM) {
                float dx = (player.x + (player.size / 2.0f)) - (c3.x + (c3.size / 2.0f));
                c = c2;
                float dy = (player.y + (player.size / 2.0f)) - (c3.y + (c3.size / 2.0f));
                i = i5;
                float dist = (float) Math.sqrt((dx * dx) + (dy * dy));
                if (dist < this.screenWidth * 0.6f) {
                    c3.x += dx * 0.15f;
                    c3.y += dy * 0.15f;
                }
            } else {
                i = i5;
                c = c2;
            }
            if (RectF.intersects(player.getCollisionRect(), c3.getCollisionRect())) {
                if (this.vibrationEnabled && this.vibrator != null) {
                    this.vibrator.vibrate(30L);
                }
                if (this.soundEnabled && this.soundLoaded) {
                    this.soundPool.play(this.soundCollect, 1.0f, 1.0f, 0, 0, 1.0f);
                }
                            int collColor = Color.parseColor("#FFD600");
            String emojiChar = "✨";
            if (c3.type == Collectible.Type.SHIELD) {
                collColor = Color.parseColor("#76FF03");
                emojiChar = "🛡️";
            } else if (c3.type == Collectible.Type.MAGNET) {
                collColor = Color.parseColor("#E91E63");
                emojiChar = "🧲";
            } else if (c3.type == Collectible.Type.GHOST) {
                collColor = Color.parseColor("#BBDEFB");
                emojiChar = "👻";
            } else if (c3.type == Collectible.Type.GEM) {
                collColor = Color.parseColor("#AA00FF");
                emojiChar = "💎";
            }
            triggerCollectEffect(c3.x + (c3.size / 2.0f), c3.y + (c3.size / 2.0f), emojiChar, collColor);
            switch (c3.type) {
                    case SHIELD:
                        player.setHasShield(true);
                        if (this.soundEnabled && this.soundLoaded) {
                            this.soundPool.play(this.soundShield, 1.0f, 1.0f, 0, 0, 1.0f);
                        }
                        break;
                    case MAGNET:
                        this.magnetTimer = 600;
                        if (this.soundEnabled && this.soundLoaded) {
                            this.soundPool.play(this.soundMagnet, 1.0f, 1.0f, 0, 0, 1.0f);
                        }
                        break;
                    case GHOST:
                        this.ghostTimer = 600;
                        if (this.soundEnabled && this.soundLoaded) {
                            this.soundPool.play(this.soundGhost, 1.0f, 1.0f, 0, 0, 1.0f);
                        }
                        break;
                    case GEM:
                        this.gems += 2;
                        this.prefs.edit().putInt("gems", this.gems).apply();
                        this.bonusScore += 50;
                        break;
                    case STAR:
                        this.bonusScore += ((int) (elapsed / 1000)) + 25;
                        if (this.feverTimer == 0) {
                            this.starCombo++;
                            if (this.starCombo >= 5) {
                                this.feverTimer = 180;
                                this.starCombo = 0;
                                if (this.vibrationEnabled && this.vibrator != null) {
                                    this.vibrator.vibrate(new long[]{0, 50, 50, 50}, -1);
                                }
                                if (this.soundEnabled && this.soundLoaded) {
                                    this.soundPool.play(this.soundFever, 1.0f, 1.0f, 0, 0, 1.0f);
                                }
                            }
                        }
                        break;
                }
                i2 = i;
                this.collectibles.remove(i2);
            } else {
                i2 = i;
                if (c3.isOffScreen(this.screenHeight)) {
                    this.collectibles.remove(i2);
                }
            }
            i5 = i2 - 1;
            c2 = c;
        }
        if (this.magnetTimer > 0) {
            this.magnetTimer--;
        }
        if (this.ghostTimer > 0) {
            this.ghostTimer--;
        }
        if (this.feverTimer > 0) {
            this.feverTimer--;
        }
        if (this.perfectDodgeIndicator > 0) {
            this.perfectDodgeIndicator--;
        }
        for (int i6 = this.obstacles.size() - 1; i6 >= 0; i6--) {
            Obstacle o = this.obstacles.get(i6);
            o.update();
            if (this.ghostTimer == 0 && this.feverTimer == 0 && RectF.intersects(player.getCollisionRect(), o.getCollisionRect())) {
                if (!player.hasShield) {
                    this.currentState = State.GAME_OVER;
                    this.combo = 0;
                    this.comboMultiplier = 1.0f;
                    this.shakeDuration = 0;
                    triggerExplosion(player.x + (player.size / 2), player.y + (player.size / 2));
                    if (this.vibrationEnabled && this.vibrator != null) {
                        this.vibrator.vibrate(new long[]{0, 100, 100, 200}, -1);
                    }
                    if (this.soundEnabled && this.soundLoaded) {
                        this.soundPool.play(this.soundCrash, 1.0f, 1.0f, 0, 0, 1.0f);
                    }
                    if (this.score > this.highScore) {
                        this.highScore = this.score;
                        this.prefs.edit().putInt("highScore", this.highScore).apply();
                    }
                } else {
                    player.setHasShield(false);
                    this.obstacles.remove(i6);
                    this.shakeDuration = 10;
                    triggerExplosion(o.x + (o.size / 2), o.y + (o.size / 2));
                    if (this.vibrationEnabled && this.vibrator != null) {
                        this.vibrator.vibrate(50L);
                    }
                    if (this.soundEnabled && this.soundLoaded) {
                        this.soundPool.play(this.soundCrash, 1.0f, 1.0f, 0, 0, 1.0f);
                    }
                }
            }
            if (o.isOffScreen(this.screenHeight)) {
                this.obstacles.remove(i6);
                this.combo++;
                this.comboMultiplier = (this.combo / 10.0f) + 1.0f;
            }
        }
        int i7 = this.shakeDuration;
        if (i7 > 0) {
            this.shakeDuration--;
        }
        updateVisuals();
    }

    private void updateVisuals() {
        for (int i = this.particles.size() - 1; i >= 0; i--) {
            this.particles.get(i).update();
            if (this.particles.get(i).isDead()) {
                this.particles.remove(i);
            }
        }
    }

    private void triggerExplosion(float x, float y) {
        int color = this.currentTheme != null ? this.currentTheme.color : Color.parseColor("#00E5FF");
        triggerExplosion(x, y, color);
    }

    private void triggerExplosion(float x, float y, int color) {
        for (int i = 0; i < 20; i++) {
            this.particles.add(new Particle(x, y, color));
        }
    }

    public float getShakeX() {
        if (this.shakeDuration > 0) {
            return (this.random.nextFloat() - 0.5f) * 20.0f;
        }
        return 0.0f;
    }

    public float getShakeY() {
        if (this.shakeDuration > 0) {
            return (this.random.nextFloat() - 0.5f) * 20.0f;
        }
        return 0.0f;
    }

    public void draw(Canvas canvas, Paint paint, Player player) {
        Canvas canvas2;
        float f;
        float f2;
        Paint paint2 = paint;
        boolean useLayer = this.transitionAlpha < 1.0f || this.isTransitioning;
        if (!useLayer) {
            canvas2 = canvas;
        } else {
            paint2.setAlpha((int) (this.transitionAlpha * 255.0f));
            canvas2 = canvas;
            canvas2.save();
            float slideOffset = (1.0f - this.transitionAlpha) * 150.0f;
            canvas2.translate(0.0f, slideOffset);
            canvas2.saveLayer(0.0f, 0.0f, this.screenWidth, this.screenHeight, paint);
            paint2 = paint;
            paint2.setAlpha(255);
        }
        for (Particle p : this.particles) {
            p.draw(canvas2, paint2);
        }
        for (Collectible c : this.collectibles) {
            c.draw(canvas2, paint2);
        }
        for (Obstacle o : this.obstacles) {
            o.draw(canvas2, paint2);
        }
        if (this.currentState == State.PLAYING) {
            paint2.setColor(-1);
            paint2.setTextSize(60.0f);
            paint2.setTextAlign(Paint.Align.CENTER);
            canvas2.drawText("Score: " + this.score, this.screenWidth / 2.0f, 100.0f, paint2);
            if (this.combo > 1) {
                paint2.setColor(Color.parseColor("#FFD600"));
                paint2.setTextSize(40.0f);
                canvas2.drawText("COMBO X" + String.format("%.1f", Float.valueOf(this.comboMultiplier)), this.screenWidth / 2.0f, 160.0f, paint2);
            }
        }
        if (this.speedUpIndicator > 0) {
            paint2.setColor(-1);
            paint2.setTextSize(80.0f);
            paint2.setAlpha(Math.min(255, this.speedUpIndicator * 10));
            canvas2.drawText("SPEED UP!", this.screenWidth / 2.0f, this.screenHeight / 3.0f, paint2);
            this.speedUpIndicator--;
        }
        if (this.levelUpIndicator > 0) {
            paint2.setColor(Color.parseColor("#FFD600"));
            paint2.setTextSize(100.0f);
            paint2.setAlpha(Math.min(255, this.levelUpIndicator * 10));
            canvas2.drawText("LEVEL UP!", this.screenWidth / 2.0f, this.screenHeight / 2.0f, paint2);
            this.levelUpIndicator--;
        }
        paint2.setTextAlign(Paint.Align.CENTER);
        paint2.setTextSize(40.0f);
        for (int i = 0; i < this.floatingTexts.size(); i++) {
            FloatingText ft = this.floatingTexts.get(i);
            paint2.setAlpha(ft.alpha);
            canvas2.drawText(ft.text, ft.x, ft.y, paint2);
        }
        paint2.setAlpha(255);
        if (this.currentState != State.PLAYING || this.countdown <= 0) {
            f = 2.0f;
            f2 = 150.0f;
        } else {
            paint2.setColor(COLOR_SURFACE);
            if (this.isInitialCountdown) {
                paint2.setAlpha(200);
                f = 2.0f;
                f2 = 150.0f;
                canvas2.drawRect(0.0f, 0.0f, this.screenWidth, this.screenHeight, paint);
                canvas2 = canvas;
                paint2 = paint;
            } else {
                f = 2.0f;
                f2 = 150.0f;
                paint2.setAlpha(120);
                canvas2 = canvas;
                canvas2.drawRect(0.0f, (this.screenHeight / 2.0f) - 150.0f, this.screenWidth, (this.screenHeight / 2.0f) + 150.0f, paint);
                paint2 = paint;
            }
            paint2.setAlpha(255);
            paint2.setColor(COLOR_PRIMARY);
            paint2.setTextSize(60.0f);
            paint2.setTextAlign(Paint.Align.CENTER);
            canvas2.drawText("LEVEL " + getCurrentLevel() + " CHALLENGE", this.screenWidth / f, (this.screenHeight / f) - 100.0f, paint2);
            paint2.setTextSize(40.0f);
            paint2.setColor(-1);
            int needed = this.levelTargetScore - this.lastLevelTargetScore;
            canvas2.drawText("Reach " + this.levelTargetScore + " Total (+" + needed + ")", this.screenWidth / f, (this.screenHeight / f) + 20.0f, paint2);
            paint2.setTextSize(30.0f);
            canvas2.drawText("to complete this level!", this.screenWidth / f, (this.screenHeight / f) + 70.0f, paint2);
        }
        drawCircularTimer(canvas2, paint2, "MAG", this.magnetTimer, 150, 0);
        drawCircularTimer(canvas, paint, "GHO", this.ghostTimer, 180, 1);
        drawCircularTimer(canvas, paint, "FEV", this.feverTimer, 180, 2);
        if (this.perfectDodgeIndicator > 0) {
            paint.setColor(Color.parseColor("#FFEB3B"));
            paint.setTextSize(60.0f);
            paint.setAlpha(Math.min(255, this.perfectDodgeIndicator * 15));
            canvas.drawText("PERFECT DODGE!", this.screenWidth / f, this.screenHeight / 4.0f, paint);
        }
        paint.setAlpha(255);
        if (this.currentState == State.MAIN_MENU) {
            drawMainMenu(canvas, paint);
        } else if (this.currentState == State.GAME_OVER) {
            drawGameOver(canvas, paint);
        } else if (this.currentState == State.PAUSED) {
            drawPauseMenu(canvas, paint);
        } else if (this.currentState == State.SHOP) {
            drawShop(canvas, paint);
        } else if (this.currentState == State.ABOUT) {
            drawAbout(canvas, paint);
        } else if (this.currentState == State.SETTINGS) {
            drawSettings(canvas, paint);
        } else if (this.currentState == State.HIGH_SCORES) {
            drawHighScores(canvas, paint);
        }
        if (this.currentState == State.PLAYING) {
            paint.setColor(-1);
            paint.setTextSize(60.0f);
            canvas.drawText("||", this.screenWidth - 80, 100.0f, paint);
            float progress = (this.score - this.lastLevelTargetScore) / (this.levelTargetScore - this.lastLevelTargetScore);
            drawProgressBar(canvas, paint, "LVL " + getCurrentLevel(), progress, this.screenWidth / f, 200.0f);
            if (getCurrentLevel() >= 5) {
                paint.setColor(-1);
                paint.setTextSize(30.0f);
                paint.setTextAlign(Paint.Align.LEFT);
                canvas.drawText("B: " + this.bullets, 30.0f, this.screenHeight - 60, paint);
                if (getCurrentLevel() >= 10) {
                    canvas.drawText("S: " + this.superBullets, f2, this.screenHeight - 60, paint);
                }
            }
        }

        if (useLayer) {
            canvas.restore();
            canvas.restore();
        }
        paint.setAlpha(255);
    }

    private void drawMainMenu(Canvas canvas, Paint paint) {
        drawOverlay(canvas, paint, "", "");
        float centerX = this.screenWidth / 2.0f;
        paint.setColor(-1);
        paint.setTextSize(120.0f);
        paint.setTextAlign(Paint.Align.CENTER);
        paint.setFakeBoldText(true);
        paint.setTypeface(android.graphics.Typeface.create("sans-serif-condensed", android.graphics.Typeface.BOLD));
        canvas.drawText("TAP SURVIVAL", centerX, this.screenHeight * 0.12f, paint);
        paint.setTypeface(null);
        paint.setFakeBoldText(false);
        drawLevelBadge(canvas, paint, centerX, this.screenHeight * 0.18f);
        float startY = this.screenHeight * 0.28f;
        float spacing = this.buttonSpacing;
        drawButton(canvas, paint, centerX, startY, "NEW GAME");
        drawButton(canvas, paint, centerX, startY + spacing, "SHOP");
        drawButton(canvas, paint, centerX, startY + (2.0f * spacing), "HIGH SCORE");
        drawButton(canvas, paint, centerX, startY + (3.0f * spacing), "SETTINGS");
        drawButton(canvas, paint, centerX, startY + (4.0f * spacing), "ABOUT");
    }

    private void drawLevelBadge(Canvas canvas, Paint paint, float x, float y) {
        int level = getCurrentLevel();
        float progress = getLevelProgress();
        String levelText = "LEVEL " + level;
        paint.setTextSize(35.0f);
        float tw = paint.measureText(levelText);
        this.badgeRect.set((x - (tw / 2.0f)) - 40.0f, y - 40.0f, (tw / 2.0f) + x + 40.0f, y + 40.0f);
        paint.setColor(COLOR_PRIMARY_CONTAINER);
        canvas.drawRoundRect(this.badgeRect, 40.0f, 40.0f, paint);
        paint.setColor(COLOR_PRIMARY);
        paint.setAlpha(100);
        canvas.drawRoundRect(this.badgeRect.left, this.badgeRect.top, this.badgeRect.left + (this.badgeRect.width() * progress), this.badgeRect.bottom, 40.0f, 40.0f, paint);
        paint.setAlpha(255);
        paint.setColor(COLOR_ON_SURFACE);
        canvas.drawText(levelText, x, y + 12.0f, paint);
    }

    private void drawGameOver(Canvas canvas, Paint paint) {
        drawOverlay(canvas, paint, "GAME OVER", "Final Score: " + this.score + "\nHigh Score: " + this.highScore);
        drawButton(canvas, paint, this.screenWidth / 2.0f, this.screenHeight * 0.7f, "RETRY");
        drawButton(canvas, paint, this.screenWidth / 2.0f, (this.screenHeight * 0.7f) + this.buttonSpacing, "MENU");
    }

    private void drawPauseMenu(Canvas canvas, Paint paint) {
        drawOverlay(canvas, paint, "PAUSED", "");
        drawButton(canvas, paint, this.screenWidth / 2.0f, this.screenHeight / 2.0f, "CONTINUE");
        drawButton(canvas, paint, this.screenWidth / 2.0f, (this.screenHeight / 2.0f) + 120.0f, "MAIN MENU");
    }

    private void drawShop(Canvas canvas, Paint paint) {
        float centerX;
        drawOverlay(canvas, paint, "OBSTACLE SHOP", "Customize the blocks you avoid!");
        float centerX2 = this.screenWidth / 2.0f;
        paint.setFakeBoldText(false);
        drawTabButton(canvas, paint, this.screenWidth * 0.15f, this.screenHeight * 0.28f, "SHAPES", this.shopTab == 0, 0.22f);
        drawTabButton(canvas, paint, this.screenWidth * 0.38f, this.screenHeight * 0.28f, "COLORS", this.shopTab == 1, 0.22f);
        drawTabButton(canvas, paint, this.screenWidth * 0.61f, this.screenHeight * 0.28f, "SKINS", this.shopTab == 2, 0.22f);
        Canvas canvas2 = canvas;
        drawTabButton(canvas2, paint, this.screenWidth * 0.85f, this.screenHeight * 0.28f, "BULLETS", this.shopTab == 3, 0.22f);
        float startY = (this.screenHeight * 0.42f) + this.shopScrollY;
        float spacing = this.itemSpacing;
        canvas2.save();
        canvas2.clipRect(0.0f, this.screenHeight * 0.34f, this.screenWidth, this.screenHeight * 0.8f);
        if (this.shopTab == 0) {
            int i = 0;
            while (i < this.obstacleShapes.size()) {
                Icon shape = this.obstacleShapes.get(i);
                float centerX3 = centerX2;
                drawItemCard(canvas2, paint, centerX3, startY + (i * spacing), shape.name, shape.price, shape.unlocked, shape == this.currentObstacleShape, null, shape);
                i++;
                canvas2 = canvas;
                centerX2 = centerX3;
            }
            centerX = centerX2;
        } else {
            centerX = centerX2;
            if (this.shopTab == 1) {
                for (int i2 = 0; i2 < this.obstacleColors.size(); i2++) {
                    ThemeColor color = this.obstacleColors.get(i2);
                    drawItemCard(canvas, paint, centerX, startY + (i2 * spacing), color.name, color.price, color.unlocked, color == this.currentObstacleColor, color, null);
                }
            } else if (this.shopTab != 2) {
                if (getCurrentLevel() >= 5) {
                    drawItemCard(canvas, paint, centerX, startY, "1 Bullet", 10, true, false, null, null);
                    paint.setColor(COLOR_ON_SURFACE);
                    paint.setTextSize(32.0f);
                    paint.setTextAlign(Paint.Align.CENTER);
                    canvas.drawText("You have: " + this.bullets, centerX, startY + 80.0f, paint);
                    if (getCurrentLevel() >= 10) {
                        drawItemCard(canvas, paint, centerX, startY + 220.0f, "Screen Clear", 15, true, false, null, null);
                        canvas.drawText("You have: " + this.superBullets, centerX, startY + 300.0f, paint);
                    } else {
                        drawItemCard(canvas, paint, centerX, startY + 220.0f, "Locked (Lvl 10)", 0, false, false, null, null);
                    }
                } else {
                    paint.setColor(COLOR_ON_SURFACE);
                    paint.setTextSize(40.0f);
                    paint.setTextAlign(Paint.Align.CENTER);
                    canvas.drawText("Bullets Unlock at Level 5", centerX, this.screenHeight * 0.5f, paint);
                }
            } else {
                for (int i3 = 0; i3 < this.allSkins.size(); i3++) {
                    ThemeColor skin = this.allSkins.get(i3);
                    drawItemCard(canvas, paint, centerX, startY + (i3 * spacing), skin.name, skin.price, skin.unlocked, skin == this.currentSkin, skin, null);
                }
            }
        }
        canvas.restore();
        drawButton(canvas, paint, centerX, this.screenHeight * 0.86f, "BACK");
    }

    private void drawItemCard(Canvas canvas, Paint paint, float x, float y, String name, int price, boolean unlocked, boolean active, ThemeColor colorPreview, Icon iconPreview) {
        Paint paint2;
        float iconX;
        float width = this.itemCardWidth;
        float height = this.itemCardHeight;
        this.tempRect.set(x - (width / 2.0f), y - (height / 2.0f), x + (width / 2.0f), (height / 2.0f) + y);
        paint.setColor(Color.BLACK);
        paint.setAlpha(30);
        canvas.drawRoundRect(this.tempRect.left + 4.0f, this.tempRect.top + 6.0f, this.tempRect.right + 4.0f, this.tempRect.bottom + 6.0f, 24.0f, 24.0f, paint);
        paint.setAlpha(255);
        paint.setColor(active ? COLOR_PRIMARY : COLOR_SURFACE_VARIANT);
        canvas.drawRoundRect(this.tempRect, 24.0f, 24.0f, paint);
        if (!active) {
            paint.setStyle(Paint.Style.STROKE);
            paint.setStrokeWidth(2.0f);
            paint.setColor(COLOR_OUTLINE);
            canvas.drawRoundRect(this.tempRect, 24.0f, 24.0f, paint);
            paint.setStyle(Paint.Style.FILL);
        }
        float iconX2 = this.tempRect.left + 60.0f;
        if (colorPreview != null) {
            paint.setColor(colorPreview.color);
            canvas.drawCircle(iconX2, y, 60.0f / 2.0f, paint);
            paint2 = paint;
            iconX = iconX2;
        } else if (iconPreview != null) {
            paint.setColor(COLOR_ON_SURFACE);
            if (iconPreview.type == Icon.Type.EMOJI) {
                paint.setTextSize(60.0f);
                paint.setTextAlign(Paint.Align.CENTER);
                canvas.drawText(iconPreview.emoji, iconX2, (60.0f / 3.0f) + y, paint);
                paint2 = paint;
                iconX = iconX2;
            } else {
                float s = 60.0f / 2.0f;
                if (iconPreview.type == Icon.Type.SQUARE) {
                    canvas.drawRect(iconX2 - s, y - s, iconX2 + s, y + s, paint);
                    paint2 = paint;
                    iconX = iconX2;
                } else if (iconPreview.type == Icon.Type.CIRCLE) {
                    canvas.drawCircle(iconX2, y, s, paint);
                    paint2 = paint;
                    iconX = iconX2;
                } else if (iconPreview.type != Icon.Type.TRIANGLE && iconPreview.type != Icon.Type.HEXAGON && iconPreview.type != Icon.Type.DIAMOND && iconPreview.type != Icon.Type.HEART && iconPreview.type != Icon.Type.PENTAGON) {
                    canvas.drawRect(iconX2 - s, y - s, iconX2 + s, y + s, paint);
                    iconX = iconX2;
                    paint2 = paint;
                } else {
                    this.tempPath.reset();
                    if (iconPreview.type == Icon.Type.TRIANGLE) {
                        this.tempPath.moveTo(iconX2, y - s);
                        this.tempPath.lineTo(iconX2 - s, y + s);
                        this.tempPath.lineTo(iconX2 + s, y + s);
                        iconX = iconX2;
                    } else if (iconPreview.type == Icon.Type.DIAMOND) {
                        this.tempPath.moveTo(iconX2, y - s);
                        this.tempPath.lineTo(iconX2 + s, y);
                        this.tempPath.lineTo(iconX2, y + s);
                        this.tempPath.lineTo(iconX2 - s, y);
                        iconX = iconX2;
                    } else if (iconPreview.type == Icon.Type.HEXAGON) {
                        int i = 0;
                        while (i < 6) {
                            float angle = (float) ((((double) i) * 3.141592653589793d) / 3.0d);
                            float px = (((float) Math.cos(angle)) * s) + iconX2;
                            float iconX3 = iconX2;
                            float py = (((float) Math.sin(angle)) * s) + y;
                            Path path = this.tempPath;
                            if (i == 0) {
                                path.moveTo(px, py);
                            } else {
                                path.lineTo(px, py);
                            }
                            i++;
                            iconX2 = iconX3;
                        }
                        iconX = iconX2;
                    } else if (iconPreview.type == Icon.Type.PENTAGON) {
                        for (int i2 = 0; i2 < 5; i2++) {
                            float angle2 = (float) (((((double) (i2 * 2)) * 3.141592653589793d) / 5.0d) - 1.5707963267948966d);
                            float px2 = iconX2 + (((float) Math.cos(angle2)) * s);
                            float py2 = (((float) Math.sin(angle2)) * s) + y;
                            Path path2 = this.tempPath;
                            if (i2 == 0) {
                                path2.moveTo(px2, py2);
                            } else {
                                path2.lineTo(px2, py2);
                            }
                        }
                        iconX = iconX2;
                    } else if (iconPreview.type == Icon.Type.HEART) {
                        iconX = iconX2;
                        this.tempPath.moveTo(iconX, (s * 0.7f) + y);
                        this.tempPath.cubicTo(iconX - s, y - (s * 0.3f), iconX - (s * 0.5f), y - (s * 1.2f), iconX2, y - (0.4f * s));
                        this.tempPath.cubicTo(iconX2 + (0.5f * s), y - (1.2f * s), iconX2 + s, y - (0.3f * s), iconX2, y + (0.7f * s));
                    } else {
                        iconX = iconX2;
                    }
                    this.tempPath.close();
                    paint2 = paint;
                    canvas.drawPath(this.tempPath, paint2);
                }
            }
        } else {
            paint2 = paint;
            iconX = iconX2;
            paint2.setTextSize(40.0f);
            paint2.setTextAlign(Paint.Align.CENTER);
            String icon = name.contains("Bullet") ? "🔫" : name.contains("Clear") ? "🧨" : "📦";
            canvas.drawText(icon, iconX, 15.0f + y, paint2);
        }
        if (active) {
            paint2.setTextSize(35.0f);
            paint2.setTextAlign(Paint.Align.RIGHT);
            canvas.drawText("✅", this.tempRect.right - 30.0f, 12.0f + y, paint2);
        }
        paint2.setTextAlign(Paint.Align.LEFT);
        paint2.setColor(active ? COLOR_ON_PRIMARY : COLOR_ON_SURFACE);
        paint2.setTextSize(38.0f);
        paint2.setFakeBoldText(true);
        canvas.drawText(name, 100.0f + iconX, y + 10.0f, paint2);
        paint2.setFakeBoldText(false);
        paint2.setTextAlign(Paint.Align.RIGHT);
        paint2.setTextSize(32.0f);
        String status = unlocked ? active ? "ACTIVE" : "SELECT" : "💎 " + price;
        canvas.drawText(status, this.tempRect.right - 40.0f, 10.0f + y, paint2);
    }

    private void drawAbout(Canvas canvas, Paint paint) {
        drawOverlay(canvas, paint, "ABOUT", "Tap Survival: Reflex Challenge");
        float centerX = this.screenWidth / 2.0f;
        paint.setColor(COLOR_ON_SURFACE);
        paint.setTextSize(40.0f);
        paint.setTextAlign(Paint.Align.CENTER);
        String[] lines = "Developed by:\nMuhammad Adrees\n+923077377945\n\nAvoid blocks, collect gems,\nsurvive as long as you can!\n\nDesigned for relaxation\nand focus.".split("\n");
        for (int i = 0; i < lines.length; i++) {
            canvas.drawText(lines[i], centerX, (this.screenHeight * 0.35f) + (i * 55), paint);
        }
        int i2 = this.screenHeight;
        drawButton(canvas, paint, centerX, i2 * 0.86f, "BACK");
    }

    private void drawSettings(Canvas canvas, Paint paint) {
        float centerX;
        drawOverlay(canvas, paint, "CHARACTER SELECT", "Customize your look!");
        float centerX2 = this.screenWidth / 2.0f;
        drawTabButton(canvas, paint, 0.2f * this.screenWidth, this.screenHeight * 0.27f, "ACTORS", this.settingsTab == 0, 0.28f);
        drawTabButton(canvas, paint, this.screenWidth * 0.5f, this.screenHeight * 0.27f, "COLORS", this.settingsTab == 1, 0.28f);
        Canvas canvas2 = canvas;
        drawTabButton(canvas2, paint, this.screenWidth * 0.8f, this.screenHeight * 0.27f, "PREFS", this.settingsTab == 2, 0.28f);
        float startY = (this.screenHeight * 0.42f) + this.settingsScrollY;
        float spacing = this.itemSpacing;
        canvas2.save();
        canvas2.clipRect(0.0f, this.screenHeight * 0.34f, this.screenWidth, this.screenHeight * 0.8f);
        if (this.settingsTab == 0) {
            int i = 0;
            while (i < this.allIcons.size()) {
                Icon icon = this.allIcons.get(i);
                int price = i < 3 ? 0 : (i - 1) * 10;
                float centerX3 = centerX2;
                drawItemCard(canvas2, paint, centerX3, startY + (i * spacing), icon.name, price, icon.unlocked, icon == this.currentIcon, null, icon);
                i++;
                canvas2 = canvas;
                centerX2 = centerX3;
            }
            centerX = centerX2;
        } else {
            centerX = centerX2;
            if (this.settingsTab == 1) {
                for (int i2 = 0; i2 < this.playerColors.size(); i2++) {
                    ThemeColor color = this.playerColors.get(i2);
                    drawItemCard(canvas, paint, centerX, startY + (i2 * spacing), color.name, color.price, color.unlocked, color == this.currentTheme, color, null);
                }
            } else {
                float prefY = this.screenHeight * 0.38f;
                drawButton(canvas, paint, centerX, prefY, "MUSIC: " + (this.musicEnabled ? "ON" : "OFF"), 0, false, this.musicEnabled, 0);
                drawButton(canvas, paint, centerX, prefY + this.buttonSpacing, "SFX: " + (this.soundEnabled ? "ON" : "OFF"), 0, false, this.soundEnabled, 0);
                drawButton(canvas, paint, centerX, prefY + (2.0f * this.buttonSpacing), "VIBRATION: " + (this.vibrationEnabled ? "ON" : "OFF"), 0, false, this.vibrationEnabled, 0);
            }
        }
        canvas.restore();
        drawButton(canvas, paint, centerX, this.screenHeight * 0.86f, "BACK");
    }

    private void drawHighScores(Canvas canvas, Paint paint) {
        drawOverlay(canvas, paint, "HIGH SCORES", "Your best performance!");
        float centerX = this.screenWidth / 2.0f;
        paint.setColor(COLOR_TERTIARY);
        paint.setTextSize(70.0f);
        paint.setFakeBoldText(true);
        canvas.drawText("BEST SCORE", centerX, this.screenHeight * 0.4f, paint);
        paint.setColor(COLOR_ON_SURFACE);
        paint.setTextSize(140.0f);
        canvas.drawText(String.valueOf(this.highScore), centerX, this.screenHeight * 0.55f, paint);
        paint.setFakeBoldText(false);
        drawButton(canvas, paint, centerX, this.screenHeight * 0.86f, "BACK");
    }

        public void updateMusicState() {
        if (this.mediaPlayer != null) {
            if (this.musicEnabled && (this.currentState == State.PLAYING || this.currentState == State.MAIN_MENU || this.currentState == State.PAUSED || this.currentState == State.SHOP || this.currentState == State.SETTINGS || this.currentState == State.ABOUT || this.currentState == State.HIGH_SCORES)) {
                if (!this.mediaPlayer.isPlaying()) {
                    this.mediaPlayer.start();
                }
            } else {
                if (this.mediaPlayer.isPlaying()) {
                    this.mediaPlayer.pause();
                }
            }
        }
    }

    public void pauseMusic() {
        if (this.mediaPlayer != null && this.mediaPlayer.isPlaying()) {
            this.mediaPlayer.pause();
        }
    }

    public void resumeMusic() {
        updateMusicState();
    }

    private float getPulse() {
        return (float) ((Math.sin(System.currentTimeMillis() / 400.0d) * 0.05d) + 1.0d);
    }

    private void drawButton(Canvas canvas, Paint paint, float x, float y, String text, int color, boolean locked, boolean active, int previewColor) {
        float width = this.buttonWidth;
        float height = this.buttonHeight;

        this.buttonRect.set(x - (width / 2.0f), y - (height / 2.0f), (width / 2.0f) + x, (height / 2.0f) + y);
        paint.setAlpha(255);
        if (locked) {
            paint.setColor(COLOR_SURFACE_VARIANT);
        } else if (active) {
            paint.setColor(COLOR_PRIMARY);
        } else {
            paint.setColor(COLOR_PRIMARY_CONTAINER);
        }
        canvas.drawRoundRect(this.buttonRect, height / 2.0f, height / 2.0f, paint);
        if (!active && !locked) {
            paint.setStyle(Paint.Style.STROKE);
            paint.setStrokeWidth(2.0f);
            paint.setColor(COLOR_OUTLINE);
            canvas.drawRoundRect(this.buttonRect, height / 2.0f, height / 2.0f, paint);
            paint.setStyle(Paint.Style.FILL);
        }
        paint.setColor(active ? COLOR_ON_PRIMARY : COLOR_ON_SURFACE);
        paint.setTextSize(36.0f);
        paint.setTextAlign(Paint.Align.CENTER);
        paint.setTypeface(android.graphics.Typeface.create("sans-serif-medium", android.graphics.Typeface.NORMAL));
        canvas.drawText(text, x, 12.0f + y, paint);
        paint.setTypeface(null);
    }

    private void drawButton(Canvas canvas, Paint paint, float x, float y, String text) {
        drawButton(canvas, paint, x, y, text, 0, false, false, 0);
    }

    public void handleTouch(float tx, float ty, Player player) {
        float f;
        float centerX = this.screenWidth / 2.0f;
        if (this.currentState != State.MAIN_MENU) {
            if (this.currentState == State.PLAYING) {
                if (tx > this.screenWidth - 150 && ty < 150.0f) {
                    pauseGame();
                    return;
                }
                if (tx > player.x - player.size && tx < player.x + (player.size * 2) && ty > player.y - player.size && ty < player.y + (player.size * 2)) {
                    long now = System.currentTimeMillis();
                    if (now - this.lastPlayerTouchTime < 400) {
                        shoot(player);
                        this.lastPlayerTouchTime = 0L;
                        return;
                    } else {
                        this.lastPlayerTouchTime = now;
                        return;
                    }
                }
                player.toggleLane();
                onPlayerToggleLane(player);
                return;
            }
            if (this.currentState == State.PAUSED) {
                if (isInside(tx, ty, this.screenWidth / 2.0f, this.screenHeight / 2.0f)) {
                    resumeGame();
                    return;
                } else {
                    if (isInside(tx, ty, this.screenWidth / 2.0f, (this.screenHeight / 2.0f) + 120.0f)) {
                        switchState(State.MAIN_MENU);
                        reset();
                        return;
                    }
                    return;
                }
            }
            if (this.currentState == State.GAME_OVER) {
                if (!isInsideButton(tx, ty, this.screenWidth / 2.0f, this.screenHeight * 0.7f)) {
                    if (isInsideButton(tx, ty, this.screenWidth / 2.0f, (this.screenHeight * 0.7f) + this.buttonSpacing)) {
                        switchState(State.MAIN_MENU);
                        reset();
                        return;
                    }
                    return;
                }
                startGame();
                return;
            }
            if (this.currentState == State.SHOP) {
                if (isInsideButton(tx, ty, this.screenWidth / 2.0f, this.screenHeight * 0.86f)) {
                    switchState(State.MAIN_MENU);
                    return;
                }
                this.lastTouchY = ty;
                if (ty > this.screenHeight * 0.24f && ty < this.screenHeight * 0.32f) {
                    if (tx < this.screenWidth * 0.25f) {
                        this.shopTab = 0;
                    } else if (tx < this.screenWidth * 0.5f) {
                        this.shopTab = 1;
                    } else if (tx < this.screenWidth * 0.75f) {
                        this.shopTab = 2;
                    } else {
                        this.shopTab = 3;
                    }
                    this.shopScrollY = 0.0f;
                    return;
                }
                if (this.shopTab == 3 && getCurrentLevel() >= 5) {
                    float listStartY = (this.screenHeight * 0.42f) + this.shopScrollY;
                    float spacing = this.itemSpacing;
                    if (isInsideItemCard(tx, ty, this.screenWidth / 2.0f, listStartY)) {
                        if (this.gems >= 10) {
                            this.gems -= 10;
                            this.bullets++;
                            f = 0.8f;
                            this.prefs.edit().putInt("gems", this.gems).putInt("bullets", this.bullets).apply();
                            if (this.vibrator != null) {
                                this.vibrator.vibrate(50L);
                            }
                        } else {
                            f = 0.8f;
                        }
                    } else {
                        f = 0.8f;
                        if (getCurrentLevel() >= 10 && isInsideItemCard(tx, ty, this.screenWidth / 2.0f, (1.5f * spacing) + listStartY) && this.gems >= 15) {
                            this.gems -= 15;
                            this.superBullets++;
                            this.prefs.edit().putInt("gems", this.gems).putInt("superBullets", this.superBullets).apply();
                            if (this.vibrator != null) {
                                this.vibrator.vibrate(new long[]{0, 50, 50, 50}, -1);
                            }
                        }
                    }
                } else {
                    f = 0.8f;
                }
                float listStartY2 = (this.screenHeight * 0.42f) + this.shopScrollY;
                float spacing2 = this.itemSpacing;
                if (this.shopTab == 0) {
                    for (int i = 0; i < this.obstacleShapes.size(); i++) {
                        float itemY = (i * spacing2) + listStartY2;
                        if (ty > this.screenHeight * 0.34f && ty < this.screenHeight * f && isInsideItemCard(tx, ty, this.screenWidth / 2.0f, itemY)) {
                            Icon shape = this.obstacleShapes.get(i);
                            if (shape.unlocked) {
                                this.currentObstacleShape = shape;
                                updateObstacleTheme();
                                this.prefs.edit().putString("currentObstacleShapeId", shape.id).apply();
                            } else if (this.gems >= shape.price) {
                                this.gems -= shape.price;
                                shape.unlocked = true;
                                this.unlockedObstacleShapesStr += "," + shape.id;
                                this.prefs.edit().putInt("gems", this.gems).putString("unlockedObstacleShapes", this.unlockedObstacleShapesStr).apply();
                            }
                        }
                    }
                    return;
                }
                if (this.shopTab == 1) {
                    for (int i2 = 0; i2 < this.obstacleColors.size(); i2++) {
                        float itemY2 = (i2 * spacing2) + listStartY2;
                        if (ty > this.screenHeight * 0.34f && ty < this.screenHeight * f && isInsideItemCard(tx, ty, this.screenWidth / 2.0f, itemY2)) {
                            ThemeColor color = this.obstacleColors.get(i2);
                            if (color.unlocked) {
                                this.currentObstacleColor = color;
                                updateObstacleTheme();
                                this.prefs.edit().putString("currentObstacleColorId", color.id).apply();
                                return;
                            } else {
                                if (this.gems >= color.price) {
                                    this.gems -= color.price;
                                    color.unlocked = true;
                                    this.unlockedThemesStr += "," + color.id;
                                    this.prefs.edit().putInt("gems", this.gems).putString("unlockedThemes", this.unlockedThemesStr).apply();
                                    return;
                                }
                                return;
                            }
                        }
                    }
                    return;
                }
                if (this.shopTab == 2) {
                    for (int i3 = 0; i3 < this.allSkins.size(); i3++) {
                        float itemY3 = (i3 * spacing2) + listStartY2;
                        if (ty > this.screenHeight * 0.34f && ty < this.screenHeight * f && isInsideItemCard(tx, ty, this.screenWidth / 2.0f, itemY3)) {
                            ThemeColor skin = this.allSkins.get(i3);
                            if (skin.unlocked) {
                                this.currentSkin = skin;
                                this.prefs.edit().putString("currentSkinId", skin.id).apply();
                                return;
                            } else {
                                if (this.gems >= skin.price) {
                                    this.gems -= skin.price;
                                    skin.unlocked = true;
                                    this.unlockedSkinsStr += "," + skin.id;
                                    this.prefs.edit().putInt("gems", this.gems).putString("unlockedSkins", this.unlockedSkinsStr).apply();
                                    return;
                                }
                                return;
                            }
                        }
                    }
                    return;
                }
                return;
            }
            if (this.currentState == State.SETTINGS) {
                if (isInsideButton(tx, ty, this.screenWidth / 2.0f, this.screenHeight * 0.86f)) {
                    switchState(State.MAIN_MENU);
                    return;
                }
                this.lastTouchY = ty;
                if (ty <= this.screenHeight * 0.24f || ty >= this.screenHeight * 0.3f) {
                    float listStartY3 = (this.screenHeight * 0.42f) + this.settingsScrollY;
                    float spacing3 = this.itemSpacing;
                    if (this.settingsTab == 0) {
                        for (int i4 = 0; i4 < this.allIcons.size(); i4++) {
                            float itemY4 = (i4 * spacing3) + listStartY3;
                            if (ty > this.screenHeight * 0.34f && ty < this.screenHeight * 0.8f && isInsideItemCard(tx, ty, this.screenWidth / 2.0f, itemY4)) {
                                Icon icon = this.allIcons.get(i4);
                                Log.d("TabSurvival", "Selected Icon: " + icon.name + " at index " + i4);
                                if (icon.unlocked) {
                                    this.currentIcon = icon;
                                    player.setIcon(icon);
                                    this.prefs.edit().putString("currentIconId", icon.id).apply();
                                    return;
                                }
                                return;
                            }
                        }
                        return;
                    }
                    if (this.settingsTab == 1) {
                        for (int i5 = 0; i5 < this.playerColors.size(); i5++) {
                            float itemY5 = (i5 * spacing3) + listStartY3;
                            if (ty > this.screenHeight * 0.34f && ty < this.screenHeight * 0.8f && isInsideItemCard(tx, ty, this.screenWidth / 2.0f, itemY5)) {
                                ThemeColor color2 = this.playerColors.get(i5);
                                if (color2.unlocked) {
                                    this.currentTheme = color2;
                                    player.setTheme(color2);
                                    this.prefs.edit().putString("currentPlayerColorId", color2.id).apply();
                                    return;
                                } else {
                                    if (this.gems >= color2.price) {
                                        this.gems -= color2.price;
                                        color2.unlocked = true;
                                        this.unlockedPlayerThemesStr += "," + color2.id;
                                        this.prefs.edit().putInt("gems", this.gems).putString("unlockedPlayerThemes", this.unlockedPlayerThemesStr).apply();
                                        return;
                                    }
                                    return;
                                }
                            }
                        }
                        return;
                    }
                    float prefY = this.screenHeight * 0.38f;
                    if (isInsideButton(tx, ty, this.screenWidth / 2.0f, prefY)) {
                        this.musicEnabled = !this.musicEnabled;
                        this.prefs.edit().putBoolean("musicEnabled", this.musicEnabled).apply();
                        updateMusicState();
                        if (this.vibrationEnabled && this.vibrator != null) {
                            this.vibrator.vibrate(50L);
                        }
                        return;
                    }
                    if (isInsideButton(tx, ty, this.screenWidth / 2.0f, prefY + this.buttonSpacing)) {
                        this.soundEnabled = !this.soundEnabled;
                        this.prefs.edit().putBoolean("soundEnabled", this.soundEnabled).apply();
                        if (this.vibrationEnabled && this.vibrator != null) {
                            this.vibrator.vibrate(50L);
                        }
                        return;
                    }
                    if (isInsideButton(tx, ty, this.screenWidth / 2.0f, prefY + (2.0f * this.buttonSpacing))) {
                        this.vibrationEnabled = !this.vibrationEnabled;
                        this.prefs.edit().putBoolean("vibrationEnabled", this.vibrationEnabled).apply();
                        if (this.vibrationEnabled && this.vibrator != null) {
                            this.vibrator.vibrate(50L);
                            return;
                        }
                        return;
                    }
                    return;
                }
                if (tx < this.screenWidth * 0.33f) {
                    this.settingsTab = 0;
                } else if (tx < this.screenWidth * 0.66f) {
                    this.settingsTab = 1;
                } else {
                    this.settingsTab = 2;
                }
                this.settingsScrollY = 0.0f;
                return;
            }
            if ((this.currentState == State.ABOUT || this.currentState == State.HIGH_SCORES) && isInsideButton(tx, ty, this.screenWidth / 2.0f, this.screenHeight * 0.86f)) {
                switchState(State.MAIN_MENU);
                return;
            }
            return;
        }
        float startY = this.screenHeight * 0.28f;
        float spacing4 = this.buttonSpacing;
        if (isInside(tx, ty, centerX, startY)) {
            startGame();
            return;
        }
        if (isInside(tx, ty, centerX, startY + spacing4)) {
            switchState(State.SHOP);
            return;
        }
        if (isInside(tx, ty, centerX, (2.0f * spacing4) + startY)) {
            switchState(State.HIGH_SCORES);
        } else if (isInside(tx, ty, centerX, (3.0f * spacing4) + startY)) {
            switchState(State.SETTINGS);
        } else if (isInside(tx, ty, centerX, (4.0f * spacing4) + startY)) {
            switchState(State.ABOUT);
        }
    }

    private void playButtonTapFeedback() {
        if (this.vibrationEnabled && this.vibrator != null) {
            this.vibrator.vibrate(15L);
        }
    }

    private boolean isInsideButton(float tx, float ty, float bx, float by) {
        boolean inside = tx > bx - (this.buttonWidth / 2.0f) && tx < (this.buttonWidth / 2.0f) + bx && ty > by - (this.buttonHeight / 2.0f) && ty < (this.buttonHeight / 2.0f) + by;
        if (inside) {
            playButtonTapFeedback();
        }
        return inside;
    }

    private boolean isInsideItemCard(float tx, float ty, float bx, float by) {
        boolean inside = tx > bx - (this.itemCardWidth / 2.0f) && tx < (this.itemCardWidth / 2.0f) + bx && ty > by - (this.itemCardHeight / 2.0f) && ty < (this.itemCardHeight / 2.0f) + by;
        if (inside) {
            playButtonTapFeedback();
        }
        return inside;
    }

    private boolean isInside(float tx, float ty, float bx, float by) {
        return isInsideButton(tx, ty, bx, by);
    }

    private void drawTabButton(Canvas canvas, Paint paint, float x, float y, String text, boolean active, float widthPercent) {
        float width = this.screenWidth * widthPercent;
        this.tempRect.set(x - (width / 2.0f), y - (80.0f / 2.0f), (width / 2.0f) + x, (80.0f / 2.0f) + y);
        if (active) {
            paint.setColor(COLOR_PRIMARY);
            canvas.drawRoundRect(this.tempRect, 40.0f, 40.0f, paint);
        } else {
            paint.setStyle(Paint.Style.STROKE);
            paint.setStrokeWidth(2.0f);
            paint.setColor(COLOR_OUTLINE);
            canvas.drawRoundRect(this.tempRect, 40.0f, 40.0f, paint);
            paint.setStyle(Paint.Style.FILL);
        }
        paint.setColor(active ? COLOR_ON_PRIMARY : COLOR_ON_SURFACE);
        paint.setTextSize(30.0f);
        paint.setTextAlign(Paint.Align.CENTER);
        canvas.drawText(text, x, 12.0f + y, paint);
    }

    private void drawTabButton(Canvas canvas, Paint paint, float x, float y, String text, boolean active) {
        drawTabButton(canvas, paint, x, y, text, active, 0.35f);
    }

    private void drawCircularTimer(Canvas canvas, Paint paint, String label, int current, int max, int index) {
        String icon;
        if (current <= 0) {
            return;
        }
        float y = (index * 130) + 280;
        this.tempRect.set(70.0f - (80.0f / 2.0f), y - (80.0f / 2.0f), (80.0f / 2.0f) + 70.0f, (80.0f / 2.0f) + y);
        paint.setStyle(Paint.Style.STROKE);
        paint.setStrokeWidth(8.0f);
        paint.setColor(COLOR_SURFACE_VARIANT);
        canvas.drawCircle(70.0f, y, 80.0f / 2.0f, paint);
        paint.setColor(label.equals("MAG") ? Color.parseColor("#E91E63") : COLOR_PRIMARY);
        float angle = (current / max) * 360.0f;
        canvas.drawArc(this.tempRect, -90.0f, angle, false, paint);
        paint.setStyle(Paint.Style.FILL);
        paint.setTextSize(40.0f);
        paint.setTextAlign(Paint.Align.CENTER);
        if (label.equals("MAG")) {
            icon = "🧲";
        } else {
            icon = label.equals("GST") ? "👻" : "🔥";
        }
        canvas.drawText(icon, 70.0f, 15.0f + y, paint);
        paint.setColor(-1);
        paint.setTextSize(32.0f);
        paint.setTextAlign(Paint.Align.LEFT);
        String timeStr = (current / 60) + "s";
        canvas.drawText(timeStr, (80.0f / 2.0f) + 70.0f + 20.0f, 10.0f + y, paint);
    }

    private void drawOverlay(Canvas canvas, Paint paint, String title, String sub) {
        paint.setColor(Color.parseColor("#0F0D13"));
        paint.setAlpha(235);
        canvas.drawRect(0.0f, 0.0f, this.screenWidth, this.screenHeight, paint);
        RadialGradient glass = new RadialGradient(this.screenWidth / 2.0f, this.screenHeight / 2.0f, this.screenWidth, 0, Color.parseColor("#1AFFFFFF"), Shader.TileMode.CLAMP);
        paint.setShader(glass);
        canvas.drawRect(0.0f, 0.0f, this.screenWidth, this.screenHeight, paint);
        paint.setShader(null);
        paint.setAlpha(255);
        if (!title.isEmpty()) {
            LinearGradient gradient = new LinearGradient(0.0f, 0.0f, 0.0f, this.screenHeight * 0.15f, Color.parseColor("#6750A4"), Color.parseColor("#381E72"), Shader.TileMode.CLAMP);
            paint.setShader(gradient);
            this.headerRect.set(0.0f, 0.0f, this.screenWidth, this.screenHeight * 0.15f);
            canvas.drawRect(this.headerRect, paint);
            paint.setShader(null);
            paint.setColor(-1);
            paint.setFakeBoldText(true);
            if (title.equals("OBSTACLE SHOP")) {
                paint.setTextSize(65.0f);
                paint.setTextAlign(Paint.Align.LEFT);
                canvas.drawText(title, 40.0f, this.screenHeight * 0.08f, paint);
                paint.setTextSize(40.0f);
                paint.setTextAlign(Paint.Align.RIGHT);
                canvas.drawText("💎 " + this.gems, this.screenWidth - 40, this.screenHeight * 0.08f, paint);
            } else {
                paint.setTextSize(75.0f);
                paint.setTextAlign(Paint.Align.CENTER);
                canvas.drawText(title, this.screenWidth / 2.0f, this.screenHeight * 0.08f, paint);
            }
            paint.setFakeBoldText(false);
        }
        if (!sub.isEmpty()) {
            paint.setTextSize(38.0f);
            paint.setColor(COLOR_SECONDARY);
            paint.setTextAlign(Paint.Align.CENTER);
            if (!sub.equals(this.lastSubText)) {
                this.cachedSubLines = sub.split("\n");
                this.lastSubText = sub;
            }
            if (this.cachedSubLines != null) {
                for (int i = 0; i < this.cachedSubLines.length; i++) {
                    canvas.drawText(this.cachedSubLines[i], this.screenWidth / 2.0f, (this.screenHeight * 0.2f) + (i * 55), paint);
                }
            }
        }
    }

    public void startGame() {
        switchState(State.PLAYING);
        this.isInitialCountdown = true;
        this.countdown = 120;
        this.lastLevelTargetScore = 0;
        this.levelTargetScore = this.random.nextInt(2501) + 4000;
        this.startTime = System.currentTimeMillis();
        this.lastSpawnTime = System.currentTimeMillis();
        this.lastItemSpawnTime = System.currentTimeMillis();
        this.score = 0;
        this.bonusScore = 0;
        this.lastObstacleX = -1.0f;
        this.magnetTimer = 0;
        this.ghostTimer = 0;
        this.feverTimer = 0;
        this.starCombo = 0;
        this.sameLaneCount = 0;
        this.hasSavedGame = false;
        this.prefs.edit().putBoolean("hasSavedGame", false).apply();
        this.obstacles.clear();
        this.collectibles.clear();
    }

    private void continueGame() {
        if (this.hasSavedGame) {
            loadGameState();
            resumeGame();
        } else {
            this.currentState = State.PLAYING;
            resumeGame();
        }
    }

    public void reset() {
        clearSavedGame();
        this.currentState = State.MAIN_MENU;
        this.score = 0;
        this.bonusScore = 0;
        this.obstacles.clear();
        this.collectibles.clear();
        this.magnetTimer = 0;
        this.ghostTimer = 0;
        this.feverTimer = 0;
        this.sameLaneCount = 0;
        this.perfectDodgeIndicator = 0;
    }

    public void onPlayerToggleLane(Player player) {
        if (this.vibrationEnabled && this.vibrator != null) {
            this.vibrator.vibrate(20L);
        }
        if (this.soundEnabled && this.soundLoaded) {
            this.soundPool.play(this.soundSwitch, 1.0f, 1.0f, 0, 0, 1.0f);
        }
        for (int i = 0; i < this.obstacles.size(); i++) {
            Obstacle o = this.obstacles.get(i);
            if (o != null) {
                float distY = Math.abs(o.y - player.y);
                boolean zIsLeftLane = player.isLeftLane();
                int i2 = this.screenWidth;
                if (zIsLeftLane) {
                    i2 *= 3;
                }
                float laneX = (i2 / 4.0f) - (o.size / 2.0f);
                if (distY < 300.0f && Math.abs(o.x - laneX) < 10.0f) {
                    this.perfectDodgeIndicator = 40;
                    this.bonusScore += 50;
                    if (!this.vibrationEnabled || this.vibrator == null) {
                        return;
                    }
                    this.vibrator.vibrate(40L);
                    return;
                }
            }
        }
    }

    public boolean isStartScreen() {
        return this.currentState == State.MAIN_MENU;
    }

    public boolean isGameOver() {
        return this.currentState == State.GAME_OVER;
    }

    public boolean isPlaying() {
        return this.currentState == State.PLAYING;
    }

    public boolean isPaused() {
        return this.currentState == State.PAUSED;
    }

    public float getObstacleSpeed() {
        return this.obstacleSpeed;
    }

    public boolean isGhostModeActive() {
        return this.ghostTimer > 0;
    }

    public boolean isFeverModeActive() {
        return this.feverTimer > 0;
    }

    public List<Obstacle> getObstacles() {
        return this.obstacles;
    }

    public boolean isShopScreen() {
        return this.currentState == State.SHOP;
    }

    public boolean isSettingsScreen() {
        return this.currentState == State.SETTINGS;
    }

    public State getCurrentState() {
        return this.currentState;
    }

    public int getCurrentLevel() {
        return this.currentLevel;
    }

    public float getLevelProgress() {
        return (this.score - this.lastLevelTargetScore) / (this.levelTargetScore - this.lastLevelTargetScore);
    }

    public void setLastTouchY(float y) {
        this.lastTouchY = y;
    }

    private void triggerCollectEffect(float x, float y, String emoji, int color) {
        this.floatingTexts.add(new FloatingText(x, y, emoji));
        triggerExplosion(x, y, color);
    }

    public void handleScroll(float currentY) {
        int listSize;
        if (this.lastTouchY != 0.0f) {
            float delta = (currentY - this.lastTouchY) * 2.0f;
            float visibleArea = this.screenHeight * 0.48f;
            if (this.currentState == State.SHOP) {
                this.shopScrollY += delta;
                if (this.shopTab == 0) {
                    listSize = this.obstacleShapes.size();
                } else {
                    int listSize2 = this.shopTab;
                    if (listSize2 == 1) {
                        listSize = this.obstacleColors.size();
                    } else {
                        int listSize3 = this.shopTab;
                        if (listSize3 == 2) {
                            listSize = this.allSkins.size();
                        } else {
                            int listSize4 = getCurrentLevel();
                            listSize = listSize4 >= 10 ? 3 : 2;
                        }
                    }
                }
                float maxScroll = Math.max(0.0f, ((listSize * this.itemSpacing) - visibleArea) + this.itemSpacing);
                if (this.shopScrollY > 0.0f) {
                    this.shopScrollY = 0.0f;
                }
                if (this.shopScrollY < (-maxScroll)) {
                    this.shopScrollY = -maxScroll;
                }
            } else if (this.currentState == State.SETTINGS) {
                this.settingsScrollY += delta;
                int listSize5 = (this.settingsTab == 0 ? this.allIcons : this.playerColors).size();
                float maxScroll2 = Math.max(0.0f, ((listSize5 * this.itemSpacing) - visibleArea) + this.itemSpacing);
                if (this.settingsScrollY > 0.0f) {
                    this.settingsScrollY = 0.0f;
                }
                if (this.settingsScrollY < (-maxScroll2)) {
                    this.settingsScrollY = -maxScroll2;
                }
            }
        }
        this.lastTouchY = currentY;
    }

    public Icon getActiveIcon() {
        return this.currentIcon;
    }

    public ThemeColor getActiveTheme() {
        return this.currentTheme;
    }

    private void switchState(State state) {
        if (state == this.currentState) {
            return;
        }
        this.nextState = state;
        this.isTransitioning = true;
        this.transitionAlpha = 1.0f;
    }

    public void pauseGame() {
        switchState(State.PAUSED);
        this.pauseStartTime = System.currentTimeMillis();
        saveGameState();
    }

    public void resumeGame() {
        switchState(State.PLAYING);
        if (this.pauseStartTime > 0) {
            this.startTime += System.currentTimeMillis() - this.pauseStartTime;
            this.pauseStartTime = 0L;
        } else if (this.hasSavedGame) {
            this.startTime = System.currentTimeMillis() - this.savedElapsedTime;
            this.hasSavedGame = false;
            this.prefs.edit().putBoolean("hasSavedGame", false).apply();
        }
    }

    private void saveGameState() {
        if (this.score > 0 || isPaused()) {
            long elapsed = System.currentTimeMillis() - this.startTime;
            if (isPaused() && this.pauseStartTime > 0) {
                elapsed = this.pauseStartTime - this.startTime;
            }
            SharedPreferences.Editor editor = this.prefs.edit();
            editor.putInt("savedScore", this.score);
            editor.putInt("savedBonusScore", this.bonusScore);
            editor.putLong("savedElapsedTime", elapsed);
            editor.putFloat("savedObstacleSpeed", this.obstacleSpeed);
            editor.putInt("savedCurrentLevel", this.currentLevel);
            editor.putInt("savedLevelTargetScore", this.levelTargetScore);
            editor.putInt("savedLastLevelTargetScore", this.lastLevelTargetScore);
            editor.putInt("savedBullets", this.bullets);
            editor.putInt("savedSuperBullets", this.superBullets);
            editor.putBoolean("hasSavedGame", true);
            editor.apply();
            this.hasSavedGame = true;
        }
    }

    private void loadGameState() {
        this.score = this.prefs.getInt("savedScore", 0);
        this.bonusScore = this.prefs.getInt("savedBonusScore", 0);
        this.savedElapsedTime = this.prefs.getLong("savedElapsedTime", 0L);
        this.obstacleSpeed = this.prefs.getFloat("savedObstacleSpeed", 15.0f);
        this.currentLevel = this.prefs.getInt("savedCurrentLevel", 1);
        this.levelTargetScore = this.prefs.getInt("savedLevelTargetScore", 5000);
        this.lastLevelTargetScore = this.prefs.getInt("savedLastLevelTargetScore", 0);
        this.bullets = this.prefs.getInt("savedBullets", 0);
        this.superBullets = this.prefs.getInt("savedSuperBullets", 0);
    }

    private void clearSavedGame() {
        this.hasSavedGame = false;
        this.prefs.edit().remove("savedScore").remove("savedElapsedTime").putBoolean("hasSavedGame", false).apply();
    }

    private void levelUp() {
        this.levelUpIndicator = 100;
        this.currentLevel++;
        this.lastLevelTargetScore = this.levelTargetScore;
        this.levelTargetScore += this.random.nextInt(2501) + 4000;
        this.isInitialCountdown = false;
        this.countdown = 120;
        if (this.soundEnabled && this.soundLoaded) {
            this.soundPool.play(this.soundLevelUp, 1.0f, 1.0f, 0, 0, 1.0f);
        }
        this.prefs.edit().putInt("currentLevel", this.currentLevel).putInt("levelTargetScore", this.levelTargetScore).putInt("lastLevelTargetScore", this.lastLevelTargetScore).apply();
        if (!this.vibrationEnabled || this.vibrator == null) {
            return;
        }
        this.vibrator.vibrate(new long[]{0, 100, 50, 100}, -1);
    }

    private void drawProgressBar(Canvas canvas, Paint paint, String label, float progress, float x, float y) {
        this.tempRect.set(x - (450.0f / 2.0f), y - (24.0f / 2.0f), (450.0f / 2.0f) + x, y + (24.0f / 2.0f));
        paint.setColor(COLOR_SURFACE_VARIANT);
        canvas.drawRoundRect(this.tempRect, 24.0f / 2.0f, 24.0f / 2.0f, paint);
        paint.setColor(COLOR_PRIMARY);
        canvas.drawRoundRect(this.tempRect.left, this.tempRect.top, this.tempRect.left + (Math.min(1.0f, progress) * 450.0f), this.tempRect.bottom, 24.0f / 2.0f, 24.0f / 2.0f, paint);
        paint.setColor(-1);
        paint.setTextSize(26.0f);
        paint.setTextAlign(Paint.Align.CENTER);
        canvas.drawText(label, x, y - 25.0f, paint);
    }

    private void shoot(Player player) {
        if (this.superBullets > 0) {
            this.superBullets--;
            this.prefs.edit().putInt("superBullets", this.superBullets).apply();
            for (Obstacle o : this.obstacles) {
                triggerExplosion(o.x + (o.size / 2), o.y + (o.size / 2));
            }
            this.obstacles.clear();
            if (this.vibrator != null) {
                this.vibrator.vibrate(new long[]{0, 50, 50, 50, 50, 50}, -1);
                return;
            }
            return;
        }
        if (this.bullets <= 0) {
            return;
        }
        this.bullets--;
        this.prefs.edit().putInt("bullets", this.bullets).apply();
        if (this.soundEnabled && this.soundLoaded) {
            this.soundPool.play(this.soundShoot, 1.0f, 1.0f, 0, 0, 1.0f);
        }
        Obstacle target = null;
        float minDist = Float.MAX_VALUE;
        for (Obstacle o2 : this.obstacles) {
            float distY = player.y - o2.y;
            if (distY > 0.0f && distY < minDist && Math.abs(o2.x - player.x) < this.screenWidth / 2.0f) {
                minDist = distY;
                target = o2;
            }
        }
        if (target != null) {
            triggerExplosion(target.x + (target.size / 2), target.y + (target.size / 2));
            this.obstacles.remove(target);
            if (!this.vibrationEnabled || this.vibrator == null) {
                return;
            }
            this.vibrator.vibrate(50L);
            return;
        }
        if (!this.vibrationEnabled || this.vibrator == null) {
            return;
        }
        this.vibrator.vibrate(20L);
    }

    public int getBackgroundSurfaceColor() {
        return this.currentSkin != null ? this.currentSkin.color : Color.parseColor("#1C1B1F");
    }
}
