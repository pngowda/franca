/*******************************************************************************
* This file has been generated by Franca's FDeployGenerator.
* Source: deployment spec 'org.example.spec.SpecCompoundHosts'
*******************************************************************************/
package org.example.spec;

import java.util.List;

import org.eclipse.emf.ecore.EObject;
import org.franca.core.franca.FField;
import org.franca.core.franca.FArgument;
import org.franca.core.franca.FAttribute;
import org.franca.deploymodel.core.FDeployedInterface;
import org.franca.deploymodel.dsl.fDeploy.FDAttribute;
import org.franca.deploymodel.dsl.fDeploy.FDCompoundOverwrites;
import org.franca.deploymodel.dsl.fDeploy.FDElement;
import org.franca.deploymodel.dsl.fDeploy.FDField;
import org.franca.deploymodel.dsl.fDeploy.FDFieldOverwrite;
import org.franca.deploymodel.dsl.fDeploy.FDProperty;

/**
 * Accessor for deployment properties for 'org.example.spec.SpecCompoundHosts' specification
 */		
public class SpecCompoundHostsInterfacePropertyAccessorRef extends AbstractSpecCompoundHostsDataPropertyAccessor
{
	
	private FDeployedInterface target;

	public SpecCompoundHostsInterfacePropertyAccessorRef (FDeployedInterface target) {
		this.target = target;
	}
	
	@Override
	public StringProp getStringProp (EObject obj) {
		String e = target.getEnum(obj, "StringProp");
		if (e==null) return null;
		return convertStringProp(e);
	}
	
	public Integer getAttributeProp (FAttribute obj) {
		return target.getInteger(obj, "AttributeProp");
	}
	
	public Integer getArgumentProp (FArgument obj) {
		return target.getInteger(obj, "ArgumentProp");
	}
	
	@Override
	public Integer getArrayProp (EObject obj) {
		return target.getInteger(obj, "ArrayProp");
	}
	
	public Integer getStructProp (EObject obj) {
		return target.getInteger(obj, "StructProp");
	}
	
	@Override
	public Integer getSFieldProp (FField obj) {
		return target.getInteger(obj, "SFieldProp");
	}
	
	public Integer getUnionProp (EObject obj) {
		return target.getInteger(obj, "UnionProp");
	}
	
	public Integer getUFieldProp (EObject obj) {
		return target.getInteger(obj, "UFieldProp");
	}
	


	public ISpecCompoundHostsDataPropertyAccessor getOverwriteAccessor (FAttribute obj) {
		FDElement fd = target.getFDElement(obj);
		FDAttribute fdAttr = (FDAttribute)fd;
		FDCompoundOverwrites overwrites = fdAttr.getOverwrites();
		if (overwrites==null)
			return this;
		else
			return new OverwriteAccessor(overwrites, this, target);
	}

	@Override
	public ISpecCompoundHostsDataPropertyAccessor getOverwriteAccessor (FField obj) {
		FDElement fd = target.getFDElement(obj);
		FDField fdField = (FDField)fd;
		FDCompoundOverwrites overwrites = fdField.getOverwrites();
		if (overwrites==null)
			return this;
		else
			return new OverwriteAccessor(overwrites, this, target);
	}
	
}
