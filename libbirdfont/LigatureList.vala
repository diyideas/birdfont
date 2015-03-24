/*
    Copyright (C) 2014 Johan Mattsson

    This library is free software; you can redistribute it and/or modify 
    it under the terms of the GNU Lesser General Public License as 
    published by the Free Software Foundation; either version 3 of the 
    License, or (at your option) any later version.

    This library is distributed in the hope that it will be useful, but 
    WITHOUT ANY WARRANTY; without even the implied warranty of 
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU 
    Lesser General Public License for more details.
*/

using Cairo;
using Math;

namespace BirdFont {

public class LigatureList : Table {
	Gee.ArrayList<Row> rows = new Gee.ArrayList<Row> ();

	public const int NEW_LIGATURE = -1;
	
	public LigatureList () {
	}

	public override Gee.ArrayList<Row> get_rows () {
		return rows;
	}

	void add_contextual_ligature (string ligature, string backtrack, string input, string lookahead) {
		Font font = BirdFont.get_current_font ();
		Ligatures ligatures = font.get_ligatures ();
		ligatures.add_contextual_ligature (ligature, backtrack, input, lookahead);
	}
	
	void add_ligature (string subst, string liga) {
		Font font = BirdFont.get_current_font ();
		Ligatures ligatures = font.get_ligatures ();
		ligatures.add_ligature (subst, liga);
	}

	public override void selected_row (Row row, int column, bool delete_button) {
		Font font = BirdFont.get_current_font ();
		Ligatures ligatures = font.get_ligatures ();
		int i;
		
		if (row.get_index () == NEW_LIGATURE && column == 0) {
			add_ligature (t_("character sequence"), t_("ligature"));
			TabContent.hide_text_input ();
		} else if (row.get_index () == NEW_LIGATURE && column == 1) {
			if (BirdFont.has_argument ("--test")) {
				add_contextual_ligature (t_("substitution"), t_("beginning"), t_("middle"), t_("end"));
				TabContent.hide_text_input ();
			}
		} else if (row.get_index () < ligatures.count ()) {
			if (ligatures.count () != 0) {
				if (delete_button) {
					return_if_fail (0 <= row.get_index () < ligatures.count ());
					ligatures.remove_at (row.get_index ());
					TabContent.hide_text_input ();
				} else if (column == 0) {
					return_if_fail (0 <= row.get_index () < ligatures.count ());
					ligatures.set_ligature (row.get_index ());
				} else if (column == 2) {
					return_if_fail (0 <= row.get_index () < ligatures.count ());
					ligatures.set_substitution (row.get_index ());
				}
			}
		} else {
			i = row.get_index () - ligatures.count ();
			if (i < ligatures.count_contextual_ligatures ()) {
				return_if_fail (0 <= i < ligatures.count_contextual_ligatures ());
				if (delete_button) {
					ligatures.remove_contextual_ligatures_at (i);
					TabContent.hide_text_input ();
				} if (column == 0) {
					ligatures.set_contextual_ligature (i);
				} else if (column == 1) {
					ligatures.set_beginning (i);
				} else if (column == 2) {
					ligatures.set_middle (i);
				} else if (column == 3) {
					ligatures.set_end (i);
				} 
			}
		}
			
		update_rows ();
		update_scrollbar ();
		font.touch ();
	}

	public override void update_rows () {
		int i;
		Font font = BirdFont.get_current_font ();
		Ligatures ligatures = font.get_ligatures ();
		Row row;
		
		rows.clear ();

		row = new Row.columns_2 (t_("New Ligature"), t_("New Contextual Substitution"), NEW_LIGATURE, false);
		rows.add (row);
		
		i = 0;
		ligatures.get_contextual_ligatures ((liga) => {
			row = new Row.columns_4 (liga.ligatures, liga.backtrack, liga.input, liga.lookahead, i);
			rows.add (row);
			i++;
		});
		
		ligatures.get_ligatures ((subst, liga) => {
			row = new Row.columns_3 (liga, "",  subst, i);
			rows.add (row);
			i++;
		});
				
		GlyphCanvas.redraw ();
	}

	public override string get_label () {
		return t_("Ligatures");
	}

	public override string get_name () {
		return "Ligatures";
	}
}

}
