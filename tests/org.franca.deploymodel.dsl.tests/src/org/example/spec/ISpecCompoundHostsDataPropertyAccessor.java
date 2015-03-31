/*******************************************************************************
* This file has been generated by Franca's FDeployGenerator.
* Source: deployment spec 'org.example.spec.SpecCompoundHosts'
*******************************************************************************/
package org.example.spec;

import org.eclipse.emf.ecore.EObject;
import org.franca.core.franca.FField;

/**
 * Interface for data deployment properties for 'org.example.spec.SpecCompoundHosts' specification
 * 
 * This is the data types related part only.
 */		
public interface ISpecCompoundHostsDataPropertyAccessor
{
	
	public enum StringProp {
		p, q, r, s, t, u, v, w, x, y, z
	}
	public StringProp getStringProp (EObject obj);
	
	public Integer getSFieldProp (FField obj);
	
	public Integer getUFieldProp (FField obj);
	
	public Integer getArrayProp (EObject obj);

	// TODO: add other data-related accessor functions here
	
	// overwrite-aware accessors
	public ISpecCompoundHostsDataPropertyAccessor getOverwriteAccessor (FField obj);

}
