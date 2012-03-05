/*
 * generated by Xtext
 */
package org.franca.core.dsl.ui;

import org.eclipse.ui.plugin.AbstractUIPlugin;
import org.eclipse.xtext.ui.editor.syntaxcoloring.IHighlightingConfiguration;
import org.eclipse.xtext.ui.editor.syntaxcoloring.ISemanticHighlightingCalculator;
import org.franca.core.dsl.ui.highlighting.FrancaHighlightingConfiguration;
import org.franca.core.dsl.ui.highlighting.FrancaSemanticHighlightingCalculator;

/**
 * Use this class to register components to be used within the IDE.
 */
public class FrancaIDLUiModule extends org.franca.core.dsl.ui.AbstractFrancaIDLUiModule {
	public FrancaIDLUiModule(AbstractUIPlugin plugin) {
		super(plugin);
	}
	
	
	// inject own highlighting configuration
	public Class<? extends IHighlightingConfiguration> bindSemanticConfig() {
		return FrancaHighlightingConfiguration.class;
	}

	// inject own semantic highlighting
	public Class<? extends ISemanticHighlightingCalculator> bindSemanticHighlightingCalculator() {
		return FrancaSemanticHighlightingCalculator.class;
	}

}
