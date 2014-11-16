import QtQuick 2.0
import harbour.fallingblocks.QmlLogger 2.0
import harbour.fallingblocks.SailfishWidgets.Utilities 1.1
import harbour.fallingblocks.FallingBlocks 1.0

Item {
    signal generate(string objectName, variant parent, variant properties)
    signal objectCompleted(variant object)

    DynamicLoader {
        id: loader
        onObjectCompleted: {
            Console.debug("BlockFactory: object constructed " + object);
            parent.objectCompleted(object)
        }

        onError: Console.error("BlockFactory: could not create component " + errorString)
    }

    onGenerate: {
        var position = -1;
        Console.debug("BlockFactory: Searching for objectName " + objectName)
        for(var i = 0; i < UIConstants.blocks.length; ++i) {
            if(UIConstants.blocks[i] === objectName) {
                position = i
                break
            }
        }

        Console.trace("BlockFactory: found position " + position)
        if(position != -1) {
            var qml = UIConstants.blocks[position] + ".qml"
            Console.trace("BlockFactory: qml " + qml)
            var component = Qt.createComponent(qml)
            loader.create(component, parent, properties)
            component.statusChanged.connect(loader.create)
        }
    }
}
