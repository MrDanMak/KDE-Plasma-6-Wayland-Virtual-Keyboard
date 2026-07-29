#ifndef SWYPEENGINE_H
#define SWYPEENGINE_H

#include <QObject>
#include <QPointF>
#include <QVector>
#include <QString>
#include <QStringList>
#include <QHash>
#include <memory>

class TrieNode {
public:
    QHash<QChar, std::shared_ptr<TrieNode>> children;
    bool isEndOfWord = false;
    int frequency = 0;
};

struct KeyLayoutMap {
    QChar key;
    QPointF center;
};

class SwypeEngine : public QObject {
    Q_OBJECT
    Q_PROPERTY(bool isSwyping READ isSwyping WRITE setIsSwyping NOTIFY isSwypingChanged)
    Q_PROPERTY(QString language READ language WRITE setLanguage NOTIFY languageChanged)

public:
    explicit SwypeEngine(QObject *parent = nullptr);
    ~SwypeEngine();

    Q_INVOKABLE void updateKeyMap(const QString &key, double x, double y);
    Q_INVOKABLE void startPath(double x, double y);
    Q_INVOKABLE void addPathPoint(double x, double y);
    Q_INVOKABLE QStringList finishPath();
    Q_INVOKABLE QStringList getSuggestions(const QString &currentText);
    Q_INVOKABLE QString getAutoCorrect(const QString &word);
    Q_INVOKABLE QString getSpellingCorrection(const QString &word);
    Q_INVOKABLE void learnWord(const QString &word);
    Q_INVOKABLE void learnWordPair(const QString &prevWord, const QString &nextWord);
    Q_INVOKABLE void setLanguage(const QString &langCode);

    bool isSwyping() const { return m_isSwyping; }
    void setIsSwyping(bool swyping);

    QString language() const { return m_currentLanguage; }

Q_SIGNALS:
    void isSwypingChanged();
    void languageChanged();
    void candidatesFound(const QStringList &candidates);

private:
    void loadLanguageDictionary(const QString &langCode);
    void loadUserDictionary();
    void saveUserDictionary();
    void insertWord(const QString &word, int freq = 100);
    double distance(const QPointF &p1, const QPointF &p2) const;
    QString sampleTrajectoryToChars() const;
    int levenshteinDistance(const QString &s1, const QString &s2) const;

    std::shared_ptr<TrieNode> m_root;
    QVector<QPointF> m_currentPath;
    QHash<QChar, QPointF> m_keyPositions;
    QHash<QString, QString> m_autoCorrectRules;
    QHash<QString, int> m_userWordFrequencies;
    QHash<QString, QHash<QString, int>> m_bigramFrequencies;
    QString m_currentLanguage = QStringLiteral("en_GB");
    bool m_isSwyping = false;
};

#endif // SWYPEENGINE_H
