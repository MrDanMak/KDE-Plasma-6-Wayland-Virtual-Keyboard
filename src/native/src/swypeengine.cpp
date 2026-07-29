#include "swypeengine.h"
#include <QtMath>
#include <QDebug>
#include <QFile>
#include <QDir>
#include <QStandardPaths>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QTextStream>
#include <algorithm>

SwypeEngine::SwypeEngine(QObject *parent)
    : QObject(parent), m_root(std::make_shared<TrieNode>()) {
    loadLanguageDictionary(QStringLiteral("en_GB"));
    loadUserDictionary();
}

SwypeEngine::~SwypeEngine() {
    saveUserDictionary();
}

void SwypeEngine::setLanguage(const QString &langCode) {
    if (m_currentLanguage != langCode) {
        m_currentLanguage = langCode;
        m_root = std::make_shared<TrieNode>();
        loadLanguageDictionary(m_currentLanguage);
        loadUserDictionary();
        Q_EMIT languageChanged();
    }
}

void SwypeEngine::loadUserDictionary() {
    QString dataDir = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    QDir().mkpath(dataDir);
    QString userDictPath = dataDir + QStringLiteral("/user_dictionary.json");

    QFile file(userDictPath);
    if (!file.exists() || !file.open(QIODevice::ReadOnly)) {
        qDebug() << "[SwypeEngine] User dictionary does not exist yet:" << userDictPath;
        return;
    }

    QJsonDocument doc = QJsonDocument::fromJson(file.readAll());
    file.close();

    if (!doc.isObject()) return;
    QJsonObject rootObj = doc.object();

    QJsonObject wordsObj = rootObj.value(QStringLiteral("words")).toObject();
    for (auto it = wordsObj.begin(); it != wordsObj.end(); ++it) {
        QString word = it.key();
        int freq = it.value().toInt(1000);
        m_userWordFrequencies[word] = freq;
        insertWord(word, freq);
    }

    QJsonObject bigramsObj = rootObj.value(QStringLiteral("bigrams")).toObject();
    for (auto it = bigramsObj.begin(); it != bigramsObj.end(); ++it) {
        QString prevWord = it.key();
        QJsonObject nextWords = it.value().toObject();
        for (auto nit = nextWords.begin(); nit != nextWords.end(); ++nit) {
            m_bigramFrequencies[prevWord][nit.key()] = nit.value().toInt(1);
        }
    }

    qDebug() << "[SwypeEngine] Loaded user dictionary with" << m_userWordFrequencies.size() << "learned words!";
}

void SwypeEngine::saveUserDictionary() {
    QString dataDir = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    QDir().mkpath(dataDir);
    QString userDictPath = dataDir + QStringLiteral("/user_dictionary.json");

    QJsonObject rootObj;

    QJsonObject wordsObj;
    for (auto it = m_userWordFrequencies.begin(); it != m_userWordFrequencies.end(); ++it) {
        wordsObj[it.key()] = it.value();
    }
    rootObj[QStringLiteral("words")] = wordsObj;

    QJsonObject bigramsObj;
    for (auto it = m_bigramFrequencies.begin(); it != m_bigramFrequencies.end(); ++it) {
        QJsonObject nextObj;
        for (auto nit = it.value().begin(); nit != it.value().end(); ++nit) {
            nextObj[nit.key()] = nit.value();
        }
        bigramsObj[it.key()] = nextObj;
    }
    rootObj[QStringLiteral("bigrams")] = bigramsObj;

    QFile file(userDictPath);
    if (file.open(QIODevice::WriteOnly)) {
        file.write(QJsonDocument(rootObj).toJson());
        file.close();
    }
}

void SwypeEngine::learnWord(const QString &word) {
    QString clean = word.trimmed();
    if (clean.length() < 1) return;

    int newFreq = m_userWordFrequencies.value(clean.toLower(), 2000) + 500;
    m_userWordFrequencies[clean.toLower()] = newFreq;
    insertWord(clean.toLower(), newFreq);
    saveUserDictionary();
}

void SwypeEngine::learnWordPair(const QString &prevWord, const QString &nextWord) {
    QString w1 = prevWord.trimmed().toLower();
    QString w2 = nextWord.trimmed().toLower();
    if (w1.isEmpty() || w2.isEmpty()) return;

    m_bigramFrequencies[w1][w2] += 1;
    learnWord(w2);
}

void SwypeEngine::loadLanguageDictionary(const QString &langCode) {
    qDebug() << "[SwypeEngine] Loading multi-language dictionary for:" << langCode;

    if (langCode == QStringLiteral("de_DE")) { // German (QWERTZ)
        m_autoCorrectRules = {
            {QStringLiteral("dass"), QStringLiteral("dass")},
            {QStringLiteral("und"), QStringLiteral("und")},
            {QStringLiteral("nicht"), QStringLiteral("nicht")},
            {QStringLiteral("uber"), QStringLiteral("über")},
            {QStringLiteral("oder"), QStringLiteral("oder")}
        };
        const QStringList germanTop = {
            QStringLiteral("die"), QStringLiteral("der"), QStringLiteral("und"), QStringLiteral("in"), QStringLiteral("zu"), QStringLiteral("den"), QStringLiteral("das"), QStringLiteral("nicht"), QStringLiteral("von"), QStringLiteral("sie"),
            QStringLiteral("ist"), QStringLiteral("des"), QStringLiteral("sich"), QStringLiteral("mit"), QStringLiteral("dem"), QStringLiteral("dass"), QStringLiteral("er"), QStringLiteral("es"), QStringLiteral("ein"), QStringLiteral("ich"),
            QStringLiteral("auf"), QStringLiteral("so"), QStringLiteral("eine"), QStringLiteral("auch"), QStringLiteral("als"), QStringLiteral("an"), QStringLiteral("nach"), QStringLiteral("wie"), QStringLiteral("im"), QStringLiteral("für")
        };
        int p = 5000;
        for (const QString &w : germanTop) insertWord(w, p--);
    } else if (langCode == QStringLiteral("fr_FR")) { // French (AZERTY)
        m_autoCorrectRules = {
            {QStringLiteral("ca"), QStringLiteral("ça")},
            {QStringLiteral("etre"), QStringLiteral("être")},
            {QStringLiteral("tres"), QStringLiteral("très")},
            {QStringLiteral("deja"), QStringLiteral("déjà")}
        };
        const QStringList frenchTop = {
            QStringLiteral("le"), QStringLiteral("de"), QStringLiteral("un"), QStringLiteral("à"), QStringLiteral("être"), QStringLiteral("et"), QStringLiteral("en"), QStringLiteral("avoir"), QStringLiteral("que"), QStringLiteral("pour"),
            QStringLiteral("dans"), QStringLiteral("ce"), QStringLiteral("il"), QStringLiteral("qui"), QStringLiteral("ne"), QStringLiteral("sur"), QStringLiteral("se"), QStringLiteral("pas"), QStringLiteral("plus"), QStringLiteral("pouvoir")
        };
        int p = 5000;
        for (const QString &w : frenchTop) insertWord(w, p--);
    } else if (langCode == QStringLiteral("es_ES")) { // Spanish
        m_autoCorrectRules = {
            {QStringLiteral("esta"), QStringLiteral("está")},
            {QStringLiteral("que"), QStringLiteral("que")},
            {QStringLiteral("tambien"), QStringLiteral("también")}
        };
        const QStringList spanishTop = {
            QStringLiteral("el"), QStringLiteral("la"), QStringLiteral("que"), QStringLiteral("de"), QStringLiteral("y"), QStringLiteral("en"), QStringLiteral("un"), QStringLiteral("ser"), QStringLiteral("se"), QStringLiteral("no"),
            QStringLiteral("haber"), QStringLiteral("por"), QStringLiteral("con"), QStringLiteral("su"), QStringLiteral("para"), QStringLiteral("como"), QStringLiteral("estar"), QStringLiteral("tener"), QStringLiteral("le"), QStringLiteral("lo")
        };
        int p = 5000;
        for (const QString &w : spanishTop) insertWord(w, p--);
    } else { // Default British English (en_GB)
        m_autoCorrectRules = {
            {QStringLiteral("color"), QStringLiteral("colour")},
            {QStringLiteral("colors"), QStringLiteral("colours")},
            {QStringLiteral("flavor"), QStringLiteral("flavour")},
            {QStringLiteral("flavors"), QStringLiteral("favours")},
            {QStringLiteral("favor"), QStringLiteral("favour")},
            {QStringLiteral("favors"), QStringLiteral("favours")},
            {QStringLiteral("behavior"), QStringLiteral("behaviour")},
            {QStringLiteral("behaviors"), QStringLiteral("behaviours")},
            {QStringLiteral("center"), QStringLiteral("centre")},
            {QStringLiteral("centers"), QStringLiteral("centres")},
            {QStringLiteral("theater"), QStringLiteral("theatre")},
            {QStringLiteral("theaters"), QStringLiteral("theatres")},
            {QStringLiteral("organize"), QStringLiteral("organise")},
            {QStringLiteral("organization"), QStringLiteral("organisation")},
            {QStringLiteral("realize"), QStringLiteral("realise")},
            {QStringLiteral("realized"), QStringLiteral("realised")},
            {QStringLiteral("minimize"), QStringLiteral("minimise")},
            {QStringLiteral("minimized"), QStringLiteral("minimised")},
            {QStringLiteral("analyze"), QStringLiteral("analyse")},
            {QStringLiteral("program"), QStringLiteral("programme")},
            {QStringLiteral("defense"), QStringLiteral("defence")},
            {QStringLiteral("offense"), QStringLiteral("offence")},
            {QStringLiteral("license"), QStringLiteral("licence")},

            // Grammar Contractions & Pronoun Capitalisation
            {QStringLiteral("i"), QStringLiteral("I")},
            {QStringLiteral("im"), QStringLiteral("I'm")},
            {QStringLiteral("ive"), QStringLiteral("I've")},
            {QStringLiteral("ill"), QStringLiteral("I'll")},
            {QStringLiteral("id"), QStringLiteral("I'd")},
            {QStringLiteral("dont"), QStringLiteral("don't")},
            {QStringLiteral("cant"), QStringLiteral("can't")},
            {QStringLiteral("wont"), QStringLiteral("won't")},
            {QStringLiteral("isnt"), QStringLiteral("isn't")},
            {QStringLiteral("arent"), QStringLiteral("aren't")},
            {QStringLiteral("wasnt"), QStringLiteral("wasn't")},
            {QStringLiteral("werent"), QStringLiteral("weren't")},
            {QStringLiteral("hasnt"), QStringLiteral("hasn't")},
            {QStringLiteral("havent"), QStringLiteral("haven't")},
            {QStringLiteral("hadnt"), QStringLiteral("hadn't")},
            {QStringLiteral("couldnt"), QStringLiteral("couldn't")},
            {QStringLiteral("wouldnt"), QStringLiteral("wouldn't")},
            {QStringLiteral("shouldnt"), QStringLiteral("shouldn't")},
            {QStringLiteral("thats"), QStringLiteral("that's")},
            {QStringLiteral("whats"), QStringLiteral("what's")},
            {QStringLiteral("theres"), QStringLiteral("there's")},
            {QStringLiteral("hes"), QStringLiteral("he's")},
            {QStringLiteral("shes"), QStringLiteral("she's")},
            {QStringLiteral("its"), QStringLiteral("it's")},

            // Typo Auto-Corrections
            {QStringLiteral("teh"), QStringLiteral("the")},
            {QStringLiteral("hte"), QStringLiteral("the")},
            {QStringLiteral("yuo"), QStringLiteral("you")},
            {QStringLiteral("waht"), QStringLiteral("what")},
            {QStringLiteral("taht"), QStringLiteral("that")},
            {QStringLiteral("hvae"), QStringLiteral("have")},
            {QStringLiteral("wtiu"), QStringLiteral("with")},
            {QStringLiteral("grammer"), QStringLiteral("grammar")},
            {QStringLiteral("speling"), QStringLiteral("spelling")},
            {QStringLiteral("recieve"), QStringLiteral("receive")},
            {QStringLiteral("seperate"), QStringLiteral("separate")},
            {QStringLiteral("definately"), QStringLiteral("definitely")},
            {QStringLiteral("occured"), QStringLiteral("occurred")},
            {QStringLiteral("untill"), QStringLiteral("until")},
            {QStringLiteral("goverment"), QStringLiteral("government")},
            {QStringLiteral("thier"), QStringLiteral("their")},
            {QStringLiteral("truely"), QStringLiteral("truly")},
            {QStringLiteral("tomorow"), QStringLiteral("tomorrow")},
            {QStringLiteral("bussiness"), QStringLiteral("business")},
            {QStringLiteral("alot"), QStringLiteral("a lot")}
        };

        const QStringList topBritishWords = {
            QStringLiteral("the"), QStringLiteral("be"), QStringLiteral("to"), QStringLiteral("of"), QStringLiteral("and"), QStringLiteral("a"), QStringLiteral("in"), QStringLiteral("that"), QStringLiteral("have"), QStringLiteral("it"),
            QStringLiteral("for"), QStringLiteral("not"), QStringLiteral("on"), QStringLiteral("with"), QStringLiteral("he"), QStringLiteral("as"), QStringLiteral("you"), QStringLiteral("do"), QStringLiteral("at"), QStringLiteral("this"),
            QStringLiteral("but"), QStringLiteral("his"), QStringLiteral("by"), QStringLiteral("from"), QStringLiteral("they"), QStringLiteral("we"), QStringLiteral("say"), QStringLiteral("her"), QStringLiteral("she"), QStringLiteral("or"),
            QStringLiteral("an"), QStringLiteral("will"), QStringLiteral("my"), QStringLiteral("one"), QStringLiteral("all"), QStringLiteral("would"), QStringLiteral("there"), QStringLiteral("their"), QStringLiteral("what"),
            QStringLiteral("so"), QStringLiteral("up"), QStringLiteral("out"), QStringLiteral("if"), QStringLiteral("about"), QStringLiteral("who"), QStringLiteral("get"), QStringLiteral("which"), QStringLiteral("go"), QStringLiteral("me"),
            QStringLiteral("when"), QStringLiteral("make"), QStringLiteral("can"), QStringLiteral("like"), QStringLiteral("time"), QStringLiteral("no"), QStringLiteral("just"), QStringLiteral("him"), QStringLiteral("know"), QStringLiteral("take"),
            QStringLiteral("people"), QStringLiteral("into"), QStringLiteral("year"), QStringLiteral("your"), QStringLiteral("good"), QStringLiteral("some"), QStringLiteral("could"), QStringLiteral("them"), QStringLiteral("see"), QStringLiteral("other"),
            QStringLiteral("than"), QStringLiteral("then"), QStringLiteral("now"), QStringLiteral("look"), QStringLiteral("only"), QStringLiteral("come"), QStringLiteral("its"), QStringLiteral("over"), QStringLiteral("think"), QStringLiteral("also"),
            QStringLiteral("back"), QStringLiteral("after"), QStringLiteral("use"), QStringLiteral("two"), QStringLiteral("how"), QStringLiteral("our"), QStringLiteral("work"), QStringLiteral("first"), QStringLiteral("well"), QStringLiteral("way"),
            QStringLiteral("even"), QStringLiteral("new"), QStringLiteral("want"), QStringLiteral("because"), QStringLiteral("any"), QStringLiteral("these"), QStringLiteral("give"), QStringLiteral("day"), QStringLiteral("most"), QStringLiteral("us"),
            QStringLiteral("colour"), QStringLiteral("favour"), QStringLiteral("flavour"), QStringLiteral("behaviour"), QStringLiteral("centre"), QStringLiteral("theatre"), QStringLiteral("organisation"), QStringLiteral("realise"), QStringLiteral("minimise"), QStringLiteral("analyse"), QStringLiteral("programme"),
            QStringLiteral("plasma"), QStringLiteral("kde"), QStringLiteral("wayland"), QStringLiteral("cachyos"), QStringLiteral("virtual"), QStringLiteral("keyboard")
        };

        int priority = 5000;
        for (const QString &word : topBritishWords) {
            insertWord(word, priority--);
        }
    }

    // Attempt loading system Hunspell dictionary
    QString dictFileName = QStringLiteral("/usr/share/hunspell/%1.dic").arg(langCode);
    QFile dictFile(dictFileName);
    if (!dictFile.exists() && langCode == QStringLiteral("en_GB")) {
        dictFile.setFileName(QStringLiteral("/usr/share/hunspell/en_GB-large.dic"));
    }
    if (!dictFile.exists()) {
        dictFile.setFileName(QStringLiteral("/usr/share/dict/words"));
    }

    if (dictFile.open(QIODevice::ReadOnly | QIODevice::Text)) {
        QTextStream in(&dictFile);
        int loadedCount = 0;
        while (!in.atEnd() && loadedCount < 40000) {
            QString line = in.readLine().trimmed();
            if (line.isEmpty()) continue;
            int slashIdx = line.indexOf(QLatin1Char('/'));
            if (slashIdx != -1) {
                line = line.left(slashIdx);
            }
            bool isAllLetters = std::all_of(line.begin(), line.end(), [](QChar c){ return c.isLetter(); });
            if (line.length() >= 1 && isAllLetters) {
                insertWord(line.toLower(), 50);
                loadedCount++;
            }
        }
        dictFile.close();
        qDebug() << "[SwypeEngine] Loaded" << langCode << "dictionary with" << loadedCount << "words!";
    }
}

void SwypeEngine::insertWord(const QString &word, int freq) {
    auto current = m_root;
    for (QChar ch : word.toLower()) {
        if (!current->children.contains(ch)) {
            current->children[ch] = std::make_shared<TrieNode>();
        }
        current = current->children[ch];
    }
    current->isEndOfWord = true;
    current->frequency = std::max(current->frequency, freq);
}

void SwypeEngine::updateKeyMap(const QString &key, double x, double y) {
    if (!key.isEmpty()) {
        m_keyPositions[key.at(0).toLower()] = QPointF(x, y);
    }
}

void SwypeEngine::startPath(double x, double y) {
    m_currentPath.clear();
    m_currentPath.append(QPointF(x, y));
    setIsSwyping(true);
}

void SwypeEngine::addPathPoint(double x, double y) {
    if (m_currentPath.isEmpty()) return;
    QPointF newPoint(x, y);
    if (distance(m_currentPath.last(), newPoint) > 5.0) {
        m_currentPath.append(newPoint);
    }
}

QStringList SwypeEngine::finishPath() {
    setIsSwyping(false);
    if (m_currentPath.size() < 3) return {};

    QChar startChar, endChar;
    double minDistStart = 1e9, minDistEnd = 1e9;

    for (auto it = m_keyPositions.begin(); it != m_keyPositions.end(); ++it) {
        double d1 = distance(m_currentPath.first(), it.value());
        if (d1 < minDistStart) {
            minDistStart = d1;
            startChar = it.key();
        }
        double d2 = distance(m_currentPath.last(), it.value());
        if (d2 < minDistEnd) {
            minDistEnd = d2;
            endChar = it.key();
        }
    }

    if (startChar.isNull() || endChar.isNull()) return {};

    struct MatchCandidate {
        QString word;
        double score;
    };
    QVector<MatchCandidate> candidates;

    std::function<void(std::shared_ptr<TrieNode>, QString)> evaluateWord;
    evaluateWord = [&](std::shared_ptr<TrieNode> node, QString word) {
        if (!node) return;
        if (node->isEndOfWord) {
            if (word.startsWith(startChar) && word.endsWith(endChar)) {
                double totalDist = 0;
                int pathIdx = 0;
                for (QChar ch : word) {
                    if (m_keyPositions.contains(ch)) {
                        QPointF keyPos = m_keyPositions[ch];
                        double minKeyDist = 1e9;
                        for (int i = pathIdx; i < m_currentPath.size(); ++i) {
                            double d = distance(m_currentPath[i], keyPos);
                            if (d < minKeyDist) {
                                minKeyDist = d;
                                pathIdx = i;
                            }
                        }
                        totalDist += minKeyDist;
                    }
                }
                double finalScore = totalDist - (node->frequency * 0.1);
                candidates.append({word, finalScore});
            }
        }
        for (auto it = node->children.begin(); it != node->children.end(); ++it) {
            evaluateWord(it.value(), word + it.key());
        }
    };

    evaluateWord(m_root, QString());

    std::sort(candidates.begin(), candidates.end(), [](const MatchCandidate &a, const MatchCandidate &b) {
        return a.score < b.score;
    });

    QStringList result;
    for (int i = 0; i < std::min<int>(5, candidates.size()); ++i) {
        result.append(candidates[i].word);
    }

    Q_EMIT candidatesFound(result);
    return result;
}

QString SwypeEngine::sampleTrajectoryToChars() const {
    QString sampled;
    QChar lastChar;

    for (const QPointF &pt : m_currentPath) {
        QChar closestKey;
        double minDist = 1e9;

        for (auto it = m_keyPositions.begin(); it != m_keyPositions.end(); ++it) {
            double d = distance(pt, it.value());
            if (d < minDist) {
                minDist = d;
                closestKey = it.key();
            }
        }

        if (!closestKey.isNull() && closestKey != lastChar) {
            sampled.append(closestKey);
            lastChar = closestKey;
        }
    }
    return sampled;
}

int SwypeEngine::levenshteinDistance(const QString &s1, const QString &s2) const {
    const int m = s1.length();
    const int n = s2.length();
    QVector<QVector<int>> dp(m + 1, QVector<int>(n + 1, 0));

    for (int i = 0; i <= m; ++i) dp[i][0] = i;
    for (int j = 0; j <= n; ++j) dp[0][j] = j;

    for (int i = 1; i <= m; ++i) {
        for (int j = 1; j <= n; ++j) {
            int cost = (s1[i - 1] == s2[j - 1]) ? 0 : 1;
            dp[i][j] = std::min({ dp[i - 1][j] + 1, dp[i][j - 1] + 1, dp[i - 1][j - 1] + cost });
        }
    }
    return dp[m][n];
}

double SwypeEngine::distance(const QPointF &p1, const QPointF &p2) const {
    double dx = p1.x() - p2.x();
    double dy = p1.y() - p2.y();
    return qSqrt(dx * dx + dy * dy);
}

void SwypeEngine::setIsSwyping(bool swyping) {
    if (m_isSwyping != swyping) {
        m_isSwyping = swyping;
        Q_EMIT isSwypingChanged();
    }
}

QString SwypeEngine::getAutoCorrect(const QString &word) {
    QString lower = word.trimmed().toLower();
    if (m_autoCorrectRules.contains(lower)) {
        return m_autoCorrectRules.value(lower);
    }
    return word;
}

QString SwypeEngine::getSpellingCorrection(const QString &word) {
    QString lower = word.trimmed().toLower();
    if (lower.isEmpty()) return word;

    if (m_autoCorrectRules.contains(lower)) {
        return m_autoCorrectRules.value(lower);
    }

    if (lower.length() < 3) return word;

    struct BestMatch {
        QString word;
        int distance;
        int freq;
    };
    BestMatch best = {QString(), 99, -1};

    std::function<void(std::shared_ptr<TrieNode>, QString)> search;
    search = [&](std::shared_ptr<TrieNode> node, QString currentStr) {
        if (!node) return;
        if (std::abs(currentStr.length() - lower.length()) > 2) return;
        if (node->isEndOfWord && std::abs(currentStr.length() - lower.length()) <= 1) {
            int dist = levenshteinDistance(lower, currentStr);
            if (dist <= 1) {
                int totalFreq = node->frequency + m_userWordFrequencies.value(currentStr, 0);
                if (dist < best.distance || (dist == best.distance && totalFreq > best.freq)) {
                    best = {currentStr, dist, totalFreq};
                }
            }
        }
        for (auto it = node->children.begin(); it != node->children.end(); ++it) {
            search(it.value(), currentStr + it.key());
        }
    };

    search(m_root, QString());

    if (!best.word.isEmpty() && best.distance <= 1 && best.freq > 100) {
        return best.word;
    }

    return word;
}

QStringList SwypeEngine::getSuggestions(const QString &currentText) {
    if (currentText.isEmpty()) {
        return QStringList{QStringLiteral("the"), QStringLiteral("and"), QStringLiteral("you"), QStringLiteral("colour")};
    }

    QString trimmed = currentText.trimmed();
    int lastSpace = trimmed.lastIndexOf(QLatin1Char(' '));
    QString lastWord = (lastSpace != -1) ? trimmed.mid(lastSpace + 1) : trimmed;
    lastWord = lastWord.toLower();

    if (currentText.endsWith(QLatin1Char(' ')) && !lastWord.isEmpty()) {
        if (m_bigramFrequencies.contains(lastWord)) {
            struct BigramCand { QString word; int count; };
            QVector<BigramCand> bigrams;
            const auto &nextMap = m_bigramFrequencies[lastWord];
            for (auto it = nextMap.begin(); it != nextMap.end(); ++it) {
                bigrams.append({it.key(), it.value()});
            }
            std::sort(bigrams.begin(), bigrams.end(), [](const BigramCand &a, const BigramCand &b){
                return a.count > b.count;
            });
            QStringList predictions;
            for (const auto &bg : bigrams) {
                predictions.append(bg.word);
                if (predictions.size() >= 4) break;
            }
            if (!predictions.isEmpty()) return predictions;
        }
    }

    if (lastWord.isEmpty()) {
        return QStringList{QStringLiteral("the"), QStringLiteral("and"), QStringLiteral("you"), QStringLiteral("colour")};
    }

    QStringList suggestions;

    if (m_autoCorrectRules.contains(lastWord)) {
        suggestions.append(m_autoCorrectRules.value(lastWord));
    }

    auto current = m_root;
    for (QChar ch : lastWord) {
        if (!current->children.contains(ch)) {
            current = nullptr;
            break;
        }
        current = current->children[ch];
    }

    if (current) {
        struct PrefixCandidate {
            QString word;
            int freq;
        };
        QVector<PrefixCandidate> candidates;

        std::function<void(std::shared_ptr<TrieNode>, QString)> collect;
        collect = [&](std::shared_ptr<TrieNode> node, QString str) {
            if (!node || candidates.size() >= 30) return;
            if (node->isEndOfWord) {
                int customBoost = m_userWordFrequencies.value(str, 0);
                candidates.append({str, node->frequency + customBoost});
            }
            for (auto it = node->children.begin(); it != node->children.end(); ++it) {
                collect(it.value(), str + it.key());
            }
        };

        collect(current, lastWord);

        std::sort(candidates.begin(), candidates.end(), [](const PrefixCandidate &a, const PrefixCandidate &b) {
            return a.freq > b.freq;
        });

        for (const auto &cand : candidates) {
            if (!suggestions.contains(cand.word)) {
                suggestions.append(cand.word);
            }
            if (suggestions.size() >= 6) break;
        }
    }

    if (suggestions.isEmpty()) {
        suggestions.append(lastWord);
    }

    return suggestions;
}
