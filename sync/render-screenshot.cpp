#include <QGuiApplication>
#include <QQuickView>
#include <QQmlEngine>
#include <QQmlContext>
#include <QQmlPropertyMap>
#include <QAbstractListModel>
#include <QFile>
#include <QTextStream>
#include <QTimer>
#include <QImage>
#include <iostream>

class MockSddm : public QObject {
    Q_OBJECT
    Q_PROPERTY(QString hostName READ hostName CONSTANT)
    Q_PROPERTY(bool canPowerOff READ canPowerOff CONSTANT)
    Q_PROPERTY(bool canReboot READ canReboot CONSTANT)
    Q_PROPERTY(bool canSuspend READ canSuspend CONSTANT)
public:
    QString hostName() const { return "cachyos"; }
    bool canPowerOff() const { return true; }
    bool canReboot() const { return true; }
    bool canSuspend() const { return true; }
public slots:
    void login(const QString &, const QString &, int) {}
};

class MockKeyboard : public QObject {
    Q_OBJECT
    Q_PROPERTY(int currentLayout READ currentLayout CONSTANT)
    Q_PROPERTY(QStringList layouts READ layouts CONSTANT)
    Q_PROPERTY(bool enabled READ enabled CONSTANT)
    Q_PROPERTY(bool capsLock READ capsLock CONSTANT)
public:
    int currentLayout() const { return 0; }
    QStringList layouts() const { return QStringList() << "us"; }
    bool enabled() const { return true; }
    bool capsLock() const { return false; }
};

class MockUserModel : public QAbstractListModel {
    Q_OBJECT
    Q_PROPERTY(int count READ rowCount CONSTANT)
    Q_PROPERTY(QString lastUser READ lastUser CONSTANT)
    Q_PROPERTY(int lastIndex READ lastIndex CONSTANT)
public:
    int rowCount(const QModelIndex &parent = QModelIndex()) const override { return 1; }
    QString lastUser() const { return "zyan"; }
    int lastIndex() const { return 0; }
    QVariant data(const QModelIndex &index, int role) const override {
        if (!index.isValid() || index.row() != 0) return QVariant();
        if (role == Qt::UserRole + 1) return "zyan";
        if (role == Qt::UserRole + 2) return "zyan";
        if (role == Qt::UserRole + 4) return "";
        return QVariant();
    }
    QHash<int, QByteArray> roleNames() const override {
        return {
            {Qt::UserRole + 1, "name"},
            {Qt::UserRole + 2, "realName"},
            {Qt::UserRole + 4, "icon"}
        };
    }
};

class MockSessionModel : public QAbstractListModel {
    Q_OBJECT
    Q_PROPERTY(int count READ rowCount CONSTANT)
    Q_PROPERTY(int lastIndex READ lastIndex CONSTANT)
public:
    int rowCount(const QModelIndex &parent = QModelIndex()) const override { return 1; }
    int lastIndex() const { return 0; }
    QVariant data(const QModelIndex &index, int role) const override {
        if (!index.isValid() || index.row() != 0) return QVariant();
        if (role == Qt::UserRole + 4) return "Niri";
        if (role == Qt::UserRole + 2) return "niri.desktop";
        return QVariant();
    }
    QHash<int, QByteArray> roleNames() const override {
        return {
            {Qt::UserRole + 2, "file"},
            {Qt::UserRole + 4, "name"}
        };
    }
};

#include "render-screenshot.moc"

int main(int argc, char *argv[]) {
    if (argc < 4) {
        std::cerr << "Usage: " << argv[0] << " <theme_dir> <layout_name> <output_png> [width] [height]" << std::endl;
        return 1;
    }

    QString themeDir = argv[1];
    QString layoutName = argv[2];
    QString outputPng = argv[3];
    int reqWidth = (argc > 4) ? std::atoi(argv[4]) : 1920;
    int reqHeight = (argc > 5) ? std::atoi(argv[5]) : 1080;

    qputenv("QT_QPA_PLATFORM", "offscreen");
    QGuiApplication app(argc, argv);

    MockSddm sddm;
    MockKeyboard keyboard;
    MockUserModel userModel;
    MockSessionModel sessionModel;

    // Use QQmlPropertyMap so properties are dynamically accessible in QML as config.<key>
    auto configMap = QQmlPropertyMap::create(&app);
    QFile confFile(themeDir + "/theme.conf");
    if (confFile.open(QIODevice::ReadOnly | QIODevice::Text)) {
        QTextStream in(&confFile);
        while (!in.atEnd()) {
            QString line = in.readLine().trimmed();
            if (line.isEmpty() || line.startsWith("#") || line.startsWith("[")) continue;
            int eq = line.indexOf('=');
            if (eq > 0) {
                QString key = line.left(eq).trimmed();
                QString val = line.mid(eq + 1).trimmed();
                configMap->insert(key, val);
            }
        }
    }
    // Explicitly set the requested layout override in the config map
    configMap->insert("layout", layoutName);

    QQuickView view;
    view.setResizeMode(QQuickView::SizeRootObjectToView);
    view.resize(reqWidth, reqHeight);

    view.rootContext()->setContextProperty("sddm", &sddm);
    view.rootContext()->setContextProperty("keyboard", &keyboard);
    view.rootContext()->setContextProperty("userModel", &userModel);
    view.rootContext()->setContextProperty("sessionModel", &sessionModel);
    view.rootContext()->setContextProperty("config", configMap);

    view.setSource(QUrl::fromLocalFile(themeDir + "/Main.qml"));
    view.show();

    // Give QML engine ample time to finish layout and render asynchronously
    QTimer::singleShot(800, [&]() {
        QImage img = view.grabWindow();
        if (img.isNull()) {
            std::cerr << "Error: Failed to grab window image." << std::endl;
            app.exit(1);
            return;
        }
        std::cout << "Rendered " << layoutName.toStdString() << " (" 
                  << img.width() << "x" << img.height() << ") -> " << outputPng.toStdString() << std::endl;
        if (!img.save(outputPng)) {
            std::cerr << "Error: Failed to save image to " << outputPng.toStdString() << std::endl;
            app.exit(1);
            return;
        }
        app.quit();
    });

    return app.exec();
}
