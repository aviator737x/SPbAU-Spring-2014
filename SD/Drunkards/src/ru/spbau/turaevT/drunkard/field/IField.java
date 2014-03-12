package ru.spbau.turaevT.drunkard.field;

import ru.spbau.turaevT.drunkard.objects.IStaticObject;

import java.util.List;

/**
 * The <tt>IField</tt> interface provides access to the game field
 */
public interface IField {
    int getWidth();
    int getHeight();
    ICell getCell(int x, int y);
    List<ICell> getNearCells(ICell cell);

    void registerStaticObject(IStaticObject object, int x, int y);
}
